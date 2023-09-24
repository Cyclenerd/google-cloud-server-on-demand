# Create monitoring dashboard for Raspberry Pi

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_dashboard
resource "google_monitoring_dashboard" "dashboard-raspi" {
  project        = google_project.my.project_id
  depends_on     = [google_monitoring_metric_descriptor.temp-monitoring]
  dashboard_json = <<EOF
{
  "dashboardFilters": [],
  "displayName": "Raspberry Pi",
  "labels": {},
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "height": 16,
        "widget": {
          "title": "🌡️ CPU Temperature",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "breakdowns": [],
                "dimensions": [],
                "measures": [],
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MAX",
                      "groupByFields": [
                        "resource.label.\"node_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MAX"
                    },
                    "filter": "metric.type=\"custom.googleapis.com/raspi/cpu/temp\" resource.type=\"generic_node\""
                  }
                }
              }
            ],
            "thresholds": [],
            "yAxis": {
              "label": "",
              "scale": "LINEAR"
            }
          }
        },
        "width": 27
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "gaugeView": {
              "lowerBound": 0,
              "upperBound": 100
            },
            "thresholds": [
              {
                "color": "YELLOW",
                "direction": "ABOVE",
                "label": "",
                "value": 50
              },
              {
                "color": "RED",
                "direction": "ABOVE",
                "label": "",
                "value": 85
              }
            ],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_MAX",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_MAX"
                },
                "filter": "metric.type=\"custom.googleapis.com/raspi/cpu/temp\" resource.type=\"generic_node\""
              }
            }
          },
          "title": "🌡️ Maximum"
        },
        "width": 10,
        "xPos": 27
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "gaugeView": {
              "lowerBound": 0,
              "upperBound": 100
            },
            "thresholds": [
              {
                "color": "YELLOW",
                "direction": "ABOVE",
                "label": "",
                "value": 50
              },
              {
                "color": "RED",
                "direction": "ABOVE",
                "label": "",
                "value": 85
              }
            ],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_MEAN",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_MEAN"
                },
                "filter": "metric.type=\"custom.googleapis.com/raspi/cpu/temp\" resource.type=\"generic_node\""
              }
            }
          },
          "title": "🌡️ Mean"
        },
        "width": 10,
        "xPos": 27,
        "yPos": 8
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "blankView": {},
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_SUM",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_SUM"
                },
                "filter": "metric.type=\"custom.googleapis.com/compute/os/images\" resource.type=\"global\" metric.label.\"image\"=monitoring.regex.full_match(\".*fedora.*\")"
              }
            }
          },
          "title": "🔵 Fedora"
        },
        "width": 9,
        "yPos": 16
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "blankView": {},
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_SUM",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_SUM"
                },
                "filter": "metric.type=\"custom.googleapis.com/compute/os/images\" resource.type=\"global\" metric.label.\"image\"=monitoring.regex.full_match(\".*ubuntu.*\")"
              }
            }
          },
          "title": "🟡 Ubuntu"
        },
        "width": 9,
        "xPos": 9,
        "yPos": 16
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "blankView": {},
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_SUM",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_SUM"
                },
                "filter": "metric.type=\"custom.googleapis.com/compute/os/images\" resource.type=\"global\" metric.label.\"image\"=monitoring.regex.full_match(\".*debian.*\")"
              }
            }
          },
          "title": "🔴 Debian"
        },
        "width": 9,
        "xPos": 18,
        "yPos": 16
      },
      {
        "height": 8,
        "widget": {
          "scorecard": {
            "blankView": {},
            "thresholds": [],
            "timeSeriesQuery": {
              "outputFullDuration": true,
              "timeSeriesFilter": {
                "aggregation": {
                  "alignmentPeriod": "60s",
                  "crossSeriesReducer": "REDUCE_SUM",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_SUM"
                },
                "filter": "metric.type=\"custom.googleapis.com/compute/os/images\" resource.type=\"global\" metric.label.\"image\"=monitoring.regex.full_match(\".*suse.*\")"
              }
            }
          },
          "title": "🟢 openSUSE"
        },
        "width": 10,
        "xPos": 27,
        "yPos": 16
      }
    ]
  }
}
EOF
}