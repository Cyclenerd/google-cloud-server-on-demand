# Create monitoring dashboard for Virtual Machines

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_dashboard
resource "google_monitoring_dashboard" "dashboard-vms" {
  project        = google_project.my.project_id
  depends_on     = [null_resource.wait-for-api]
  dashboard_json = <<EOF
{
  "dashboardFilters": [],
  "displayName": "VMs",
  "labels": {},
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "height": 16,
        "widget": {
          "title": "Reserved vCPUs",
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
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "resource.label.\"project_id\""
                      ],
                      "perSeriesAligner": "ALIGN_SUM"
                    },
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/reserved_cores\" resource.type=\"gce_instance\""
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
        "width": 24
      },
      {
        "height": 16,
        "widget": {
          "title": "Provisioned Disk Size",
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
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "resource.label.\"project_id\""
                      ],
                      "perSeriesAligner": "ALIGN_SUM"
                    },
                    "filter": "metric.type=\"compute.googleapis.com/instance/disk/provisioning/size\" resource.type=\"gce_instance\""
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
        "width": 24,
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
                  "perSeriesAligner": "ALIGN_MAX"
                },
                "filter": "metric.type=\"compute.googleapis.com/instance/cpu/guest_visible_vcpus\" resource.type=\"gce_instance\""
              }
            }
          },
          "title": "Total vCPUs"
        },
        "width": 16,
        "xPos": 24
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
                  "perSeriesAligner": "ALIGN_MAX"
                },
                "filter": "metric.type=\"compute.googleapis.com/instance/disk/provisioning/size\" resource.type=\"gce_instance\""
              }
            }
          },
          "title": "Total Disk Size"
        },
        "width": 16,
        "xPos": 24,
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
                  "alignmentPeriod": "86400s",
                  "crossSeriesReducer": "REDUCE_MAX",
                  "groupByFields": [],
                  "perSeriesAligner": "ALIGN_MAX"
                },
                "filter": "metric.type=\"compute.googleapis.com/instance/uptime_total\" resource.type=\"gce_instance\""
              }
            }
          },
          "title": "Maximum Uptime"
        },
        "width": 16,
        "xPos": 24,
        "yPos": 16
      }
    ]
  }
}
EOF
}