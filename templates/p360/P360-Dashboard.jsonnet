local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;

grafana.dashboard.new(
  'P360-Dashboard',
  refresh='1m',
  time_from='now-5m',
  uid='gFe4axRZz',
  id=585,
  editable=true,
  tags=['P360'],
  description='P360-Dashboard',
)
.addAnnotation(
  grafana.annotation.datasource(
    name='Annotations & Alerts',
    datasource='-- Grafana --',
    type='dashboard',
    tags=['dashboard'],
    enable=true,
    hide=true,
  )
)
.addTemplate(
  grafana.template.datasource(
    'PROMETHEUS_DS',
    'prometheus',
    'P360ProdELRCore Prom',
    label='DataSource',
	regex='^P360(Dev|Prod)(.*)',
  )
)
.addTemplate(
  template.new(
    'kubernetes_name',
    '$PROMETHEUS_DS',
    'label_values(jvm_buffer_memory_used_bytes, kubernetes_name)',
    label='Kubernetes_Name',
    refresh='time',
    current='prior-auth-api',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(jvm_buffer_memory_used_bytes{kubernetes_name="$kubernetes_name"}, instance)',
    label='Instance',
    refresh='time',
    current='10.244.11.77:8089',
  )
)
.addRow(
  row.new(
    title="Base statistics",
    height='125px',
  )
  .addPanel(
    singlestat.new(
      'uptime',
      format='s',
      datasource='$PROMETHEUS_DS',
      span=4,
      valueName='current',
    )
    .addTarget(
      prometheus.target(
        expr='process_uptime_seconds{kubernetes_name="$kubernetes_name", instance="$instance"}',
      )
    )
  )
  .addPanel(
      singlestat.new(
        'start time',
        format='dateTimeAsIso',
        datasource='$PROMETHEUS_DS',
        span=4,
        valueName='current',
      )
      .addTarget(
        prometheus.target(
          expr='process_start_time_seconds{kubernetes_name="$kubernetes_name", instance="$instance"}*1000',
        )
      )
  )
  .addPanel(
      singlestat.new(
        'Heap used',
        format='percent',
        gaugeShow=true,
        gaugeThresholdMarkers=true,
        datasource='$PROMETHEUS_DS',
        span=2,
        valueName='current',
      )
      .addTarget(
        prometheus.target(
          expr='sum(jvm_memory_used_bytes{kubernetes_name="$kubernetes_name", instance="$instance", area="heap"})*100/sum(jvm_memory_max_bytes{kubernetes_name="$kubernetes_name",instance="$instance", area="heap"})',
        )
      )
  )
  .addPanel(
      singlestat.new(
        'Non-Heap used',
        format='percent',
        gaugeShow=true,
        gaugeThresholdMarkers=true,
        datasource='$PROMETHEUS_DS',
        span=2,
        valueName='current',
      )
      .addTarget(
        prometheus.target(
          expr='sum(jvm_memory_used_bytes{kubernetes_name="$kubernetes_name", instance="$instance", area="nonheap"})*100/sum(jvm_memory_max_bytes{kubernetes_name="$kubernetes_name",instance="$instance", area="nonheap"})',
        )
      )
  )
)
.addRow(
  row.new(
    title="Usage & Open files",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Open Files',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='process_files_open{kubernetes_name="$kubernetes_name", instance="$instance"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Open Files'
      )
    )
    .addTarget(
      prometheus.target(
        expr='process_files_max{kubernetes_name="$kubernetes_name", instance="$instance"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Max Files'
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'CPU Usage',
      span=4,
      format='percent',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='100*system_cpu_usage{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='System CPU Usage',
      )
    )
    .addTarget(
      prometheus.target(
        expr='100*process_cpu_usage{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Process CPU Usage',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Load Average',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='system_load_average_1m{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='System Load Average'
      )
    )
    .addTarget(
      prometheus.target(
        expr='system_cpu_count{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='System CPU Count'
      )
    )
  )
)
.addRow(
  row.new(
    title="JVM Statistics - Memory",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'All (Heap)',
      span=4,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_used_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_heap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Memory Usage',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_committed_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_heap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Memory Committed',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_max_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_heap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Max Memory',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Classes Unloaded',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_classes_unloaded_classes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Classes Unloaded',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Classes Loaded',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_classes_loaded_classes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Classes Loaded',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'All (non-heap)',
      span=4,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_used_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_nonheap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Non-heap Memory Used',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_committed_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_nonheap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Non-heap Memory Committed',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_memory_max_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="$memory_pool_nonheap"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Non-heap Memory max',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Mapped Buffers',
      span=4,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='jvm_buffer_memory_used_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="mapped"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Buffer Memory Used',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_buffer_total_capacity_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="mapped"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Buffer Total Capacity',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Threads',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='jvm_threads_daemon_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Dameon Threads',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_threads_live_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Live Threads',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_threads_peak_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Peak Threads',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Direct Buffers',
      span=4,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='jvm_buffer_memory_used_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="direct"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Direct Buffer Memory',
      )
    )
    .addTarget(
      prometheus.target(
        expr='jvm_buffer_total_capacity_bytes{instance="$instance", kubernetes_name="$kubernetes_name", id="direct"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM Direct Total Capacity',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Memory Allocate/Promote',
      span=4,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_gc_memory_allocated_bytes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM GC Allocated Memory',
      )
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_gc_memory_promoted_bytes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='JVM GC Promoted Memory',
      )
    )
  )
)
.addRow(
  row.new(
    title="JVM Statistics - GC",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'GC Count',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_gc_pause_seconds_count{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{action}} [{{cause}}]',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'GC Pause Duration',
      span=6,
      format='s',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(jvm_gc_pause_seconds_sum{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{action}} [{{cause}}]',
      )
    )
  )
)
.addRow(
  row.new(
    title="HTTP Statistics",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Request Count',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(http_server_requests_seconds_count{instance="$instance", kubernetes_name="$kubernetes_name", uri!~".*actuator.*"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}} [{{status}}] - {{uri}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Response Time',
      span=6,
      format='ms',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(http_server_requests_seconds_sum{instance="$instance", kubernetes_name="$kubernetes_name", exception="None", uri!~".*actuator.*"}[5m]) / irate(http_server_requests_seconds_count{instance="$instance", kubernetes_name="$kubernetes_name", exception="None", uri!~".*actuator.*"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}} [{{status}}] - {{uri}}',
      )
    )
  )
)
.addRow(
  row.new(
    title="Tomcat Statistics",
    height='250px',
  )
  .addPanel(
    singlestat.new(
      'Tomcat Error Count',
      format='none',
      datasource='$PROMETHEUS_DS',
      span=3,
      valueName='current',
    )
    .addTarget(
      prometheus.target(
        expr='tomcat_global_error_total{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
      )
    )
  )
  .addPanel(
    singlestat.new(
      'Thread Max Config',
      format='none',
      datasource='$PROMETHEUS_DS',
      span=3,
      valueName='current',
    )
    .addTarget(
      prometheus.target(
        expr='tomcat_threads_config_max_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Sent & Received Bytes',
      span=6,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(tomcat_global_sent_bytes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Sent Bytes',
      )
    )
    .addTarget(
      prometheus.target(
        expr='irate(tomcat_global_received_bytes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Received Bytes',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Threads',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='tomcat_threads_current_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Current Threads',
      )
    )
    .addTarget(
      prometheus.target(
        expr='tomcat_threads_busy_threads{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Busy Threads',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Active Sessions',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='tomcat_sessions_active_current_sessions{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Active Sessions',
      )
    )
  )
)
.addRow(
  row.new(
    title="Logback Statistics",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Error Logs',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(logback_events_total{instance="$instance", kubernetes_name="$kubernetes_name", level="error"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Error',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Warn Logs',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(logback_events_total{instance="$instance", kubernetes_name="$kubernetes_name", level="warn"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Warn',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Info Logs',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(logback_events_total{instance="$instance", kubernetes_name="$kubernetes_name", level="info"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Info',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Debug Logs',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(logback_events_total{instance="$instance", kubernetes_name="$kubernetes_name", level="debug"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='debug',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Trace Logs',
      span=4,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(logback_events_total{instance="$instance", kubernetes_name="$kubernetes_name", level="trace"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Trace',
      )
    )
  )
)
.addRow(
  row.new(
    title="Kafka Statistics",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Consumer Lag',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='kafka_consumer_records_lag_records{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{client_id}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Consumed Bytes Rate',
      span=6,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(kafka_consumer_bytes_consumed_total_bytes_total{instance="$instance", kubernetes_name="$kubernetes_name"}[2m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{client_id}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Number of Connections',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='kafka_consumer_connection_count_connections{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{client_id}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Heartbeat response time in max seconds',
      span=6,
      format='s',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='kafka_consumer_heartbeat_response_time_max_seconds{instance="$instance", kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{client_id}}',
      )
    )
  )
)
.addRow(
  row.new(
    title="Cassandra Statistics",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Client Timeouts',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='irate(cassandra_cluster_client_timeouts_total{instance="$instance",job="kubernetes-service-endpoints",kubernetes_name="$kubernetes_name"}[2m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Cassandra client timeout',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Latency',
      span=6,
      format='s',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='irate(cassandra_cluster_requests_seconds_count{instance="$instance",job="kubernetes-service-endpoints",kubernetes_name="$kubernetes_name"}[2m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Cassandra Latency',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Bytes Sent/Received',
      span=6,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='irate(cassandra_cluster_bytes_received_total{instance="$instance",job="kubernetes-service-endpoints",kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Bytes Received',
      )
    )
    .addTarget(
      prometheus.target(
        expr='irate(cassandra_cluster_bytes_sent_total{instance="$instance",job="kubernetes-service-endpoints",kubernetes_name="$kubernetes_name"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='Bytes Sent',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Open Connections',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='cassandra_cluster_open_connections{instance="$instance",job="kubernetes-service-endpoints",kubernetes_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Cassandra Open Connections',
      )
    )
  )
)
.addRow(
  row.new(
    title="Node Statistics",
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'CPU Usage',
      span=6,
      format='ms',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=false,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_cpu_usage_seconds_total:sum_rate5m{instance="$instance",container_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Node CPU Usage',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'CPU Load Average',
      span=6,
      format='s',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=false,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_cpu_load_average_10s:avg_rate5m{instance="$instance",container_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='CPU Load Average',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Memory Usage/Cache',
      span=6,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_memory_cache:avg_rate5m{instance="$instance",container_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Memory Cache',
      )
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_memory_usage_bytes:avg_rate5m{instance="$instance",container_name="$kubernetes_name"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Memory Usage',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Network Send/Received Bytes',
      span=6,
      format='bytes',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_network_receive_bytes_total:avg_rate5m{instance="$instance"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Network Received Bytes',
      )
    )
    .addTarget(
      prometheus.target(
        expr='namespace_container_name_instance:container_network_transmit_bytes_total:avg_rate5m{instance="$instance"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='Network Sent Bytes',
      )
    )
  )
)