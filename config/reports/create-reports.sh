#!/bin/bash
set -eo pipefail


# Source environment variables if missing
export ACCESS_TOKEN="${ACCESS_TOKEN:-$(gcloud auth application-default print-access-token 2>/dev/null || gcloud auth print-access-token 2>/dev/null || true)}"
export PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"

: "${PROJECT_ID:?PROJECT_ID environment variable is required}"
: "${ACCESS_TOKEN:?ACCESS_TOKEN environment variable is required}"

  #  Custom Analytics Reports (Fault-tolerant)
  echo "Configuring Apigee Custom Reports..."
  # Cost Report
  curl -s -X POST "https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}/reports" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{
      "name": "ai_token_cost_by_model_user",
      "displayName": "AI Token Cost by Model and User",
      "chartType": "col",
      "timeUnit": "day",
      "metrics": [
        {"name": "dc_ai_total_cost", "function": "sum"},
        {"name": "dc_ai_request_cost", "function": "sum"},
        {"name": "dc_ai_response_cost", "function": "sum"}
      ],
      "dimensions": ["dc_ai_model", "developer_email"]
    }' >/dev/null 2>&1 || true

  # Model Latency Report
  curl -s -X POST "https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}/reports" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{
      "name": "ai_model_usage_latency",
      "displayName": "AI Model Usage and Latency",
      "chartType": "col",
      "timeUnit": "hour",
      "metrics": [
        {"name": "dc_ai_total_token_count", "function": "sum"},
        {"name": "dc_ai_time_first_token", "function": "avg"},
        {"name": "message_count", "function": "sum"}
      ],
      "dimensions": ["apiproxy", "dc_ai_model", "dc_ai_response_type"]
    }' >/dev/null 2>&1 || true

  # Model Tokens Report
  curl -s -X POST "https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}/reports" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{
      "name": "ai_token_counts_by_model_user",
      "displayName": "AI Token Counts by Model and User",
      "chartType": "col",
      "timeUnit": "day",
      "metrics": [
        {"name": "dc_ai_total_token_count", "function": "sum"},
        {"name": "dc_ai_prompt_token_count", "function": "sum"},
        {"name": "dc_ai_response_token_count", "function": "sum"}
      ],
      "dimensions": ["dc_ai_model", "developer_email"]
    }' >/dev/null 2>&1 || true

echo "=== REPORTS COMPLETED ==="
