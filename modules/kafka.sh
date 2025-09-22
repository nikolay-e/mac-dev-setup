#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Data Streaming & Kafka
# --------------------------------------------------------------------

# Kafka CLI with environment checks
kcatp() {
    if [[ -z "$KAFKA_BROKERS" ]]; then
        echo " Error: Set KAFKA_BROKERS environment variable first"
        echo "Example: export KAFKA_BROKERS='localhost:9092'"
        return 1
    fi
    kcat -P -b "$KAFKA_BROKERS" -t "$@"
}

kcatc() {
    if [[ -z "$KAFKA_BROKERS" ]]; then
        echo " Error: Set KAFKA_BROKERS environment variable first"
        echo "Example: export KAFKA_BROKERS='localhost:9092'"
        return 1
    fi
    kcat -C -b "$KAFKA_BROKERS" -t "$@"
}

kcatl() {
    if [[ -z "$KAFKA_BROKERS" ]]; then
        echo " Error: Set KAFKA_BROKERS environment variable first"
        echo "Example: export KAFKA_BROKERS='localhost:9092'"
        return 1
    fi
    kcat -L -b "$KAFKA_BROKERS" "$@"
}

# Kafka topic helpers
kcat-tail() {
    if [ -z "$1" ]; then
        echo "Usage: kcat-tail <topic> [partition]"
        return 1
    fi
    kcat -C -b "$KAFKA_BROKERS" -t "$1" -o -10 "$@"
}

kcat-produce-json() {
    if [ -z "$1" ]; then
        echo "Usage: kcat-produce-json <topic>"
        echo "Then input JSON messages (Ctrl+D to end)"
        return 1
    fi
    kcat -P -b "$KAFKA_BROKERS" -t "$1" -T
}
