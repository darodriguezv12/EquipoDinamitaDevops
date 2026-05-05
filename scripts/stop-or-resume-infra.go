package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type config struct {
	region       string
	cluster      string
	service      string
	desiredCount int
}

type ecsServiceCounts struct {
	desired int
	running int
	pending int
	status  string
}

func main() {
	cfg := config{}

	flag.StringVar(&cfg.region, "region", envOrDefault("REGION", "us-east-1"), "AWS region")
	flag.StringVar(&cfg.cluster, "cluster", envOrDefault("CLUSTER_NAME", "blacklist-api-dev-cluster"), "ECS cluster name")
	flag.StringVar(&cfg.service, "service", envOrDefault("SERVICE_NAME", "blacklist-api-dev-service"), "ECS service name")
	flag.IntVar(&cfg.desiredCount, "desired-count", envIntOrDefault("DESIRED_COUNT", 1), "ECS desired count when starting")
	flag.Usage = usage
	flag.Parse()

	if flag.NArg() != 1 {
		usage()
		os.Exit(2)
	}

	var err error
	switch flag.Arg(0) {
	case "stop":
		err = stop(cfg)
	case "start":
		err = start(cfg)
	default:
		usage()
		os.Exit(2)
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintf(flag.CommandLine.Output(), "Usage: go run ./scripts/academic-infra.go [flags] <start|stop>\n\n")
	flag.PrintDefaults()
}

func stop(cfg config) error {
	step("Setting ECS service desired count to 0")
	if err := runQuiet("aws", "ecs", "update-service",
		"--cluster", cfg.cluster,
		"--service", cfg.service,
		"--desired-count", "0",
		"--region", cfg.region,
		"--no-cli-pager"); err != nil {
		return err
	}

	step("Waiting for ECS service to stop running tasks")
	if err := waitForECSCounts(cfg, 0); err != nil {
		return err
	}

	fmt.Println()
	fmt.Println("Academic infra paused by stopping Fargate tasks.")
	fmt.Println("Note: RDS and the Application Load Balancer still exist and may continue generating cost.")
	fmt.Println(`For the lowest cost, run: terraform -chdir="terraform/environments/dev" destroy`)
	return nil
}

func start(cfg config) error {
	step(fmt.Sprintf("Setting ECS service desired count to %d", cfg.desiredCount))
	if err := runQuiet("aws", "ecs", "update-service",
		"--cluster", cfg.cluster,
		"--service", cfg.service,
		"--desired-count", strconv.Itoa(cfg.desiredCount),
		"--region", cfg.region,
		"--no-cli-pager"); err != nil {
		return err
	}

	step("Waiting for ECS service to reach desired running count")
	if err := waitForECSCounts(cfg, cfg.desiredCount); err != nil {
		return err
	}

	fmt.Println()
	fmt.Println("Academic infra resumed. Use the Terraform output alb_dns_name to test the API.")
	return nil
}

func waitForECSCounts(cfg config, desired int) error {
	const attempts = 40
	const delay = 15 * time.Second

	for attempt := 1; attempt <= attempts; attempt++ {
		counts, err := ecsCounts(cfg)
		if err != nil {
			return err
		}

		step(fmt.Sprintf(
			"ECS status=%s desired=%d running=%d pending=%d",
			counts.status,
			counts.desired,
			counts.running,
			counts.pending,
		))

		if counts.desired == desired && counts.running == desired && counts.pending == 0 {
			return nil
		}

		if attempt < attempts {
			time.Sleep(delay)
		}
	}

	return fmt.Errorf("ECS service did not reach desired=%d before timeout", desired)
}

func ecsCounts(cfg config) (ecsServiceCounts, error) {
	out, err := output("aws", "ecs", "describe-services",
		"--cluster", cfg.cluster,
		"--services", cfg.service,
		"--region", cfg.region,
		"--query", "services[0].[desiredCount,runningCount,pendingCount,status]",
		"--output", "text")
	if err != nil {
		return ecsServiceCounts{}, err
	}

	fields := strings.Fields(out)
	if len(fields) != 4 {
		return ecsServiceCounts{}, fmt.Errorf("unexpected ECS describe-services output: %q", strings.TrimSpace(out))
	}

	desired, err := strconv.Atoi(fields[0])
	if err != nil {
		return ecsServiceCounts{}, err
	}
	running, err := strconv.Atoi(fields[1])
	if err != nil {
		return ecsServiceCounts{}, err
	}
	pending, err := strconv.Atoi(fields[2])
	if err != nil {
		return ecsServiceCounts{}, err
	}

	return ecsServiceCounts{
		desired: desired,
		running: running,
		pending: pending,
		status:  fields[3],
	}, nil
}

func step(message string) {
	fmt.Printf("==> %s\n", message)
}

func runQuiet(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func output(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	return string(out), err
}

func envOrDefault(name string, fallback string) string {
	value := strings.TrimSpace(os.Getenv(name))
	if value == "" {
		return fallback
	}
	return value
}

func envIntOrDefault(name string, fallback int) int {
	value := strings.TrimSpace(os.Getenv(name))
	if value == "" {
		return fallback
	}

	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}
