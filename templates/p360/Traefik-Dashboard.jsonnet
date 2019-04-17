local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;

grafana.dashboard.new(
  'Traefik-Dashboard',
  refresh='1m',
  time_from='now-60m',
  editable=true,
  tags=['P360', 'Traefik'],
  description='Traefik-Dashboard',
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
    'P360DevCTCCore Prom',
    label='DataSource',
	regex='^P360(.*)',
  )
)
.addTemplate(
  template.new(
    'job',
    '$PROMETHEUS_DS',
    'label_values(traefik_backend_requests_total,job)',
    label='Job',
    refresh='time',
    current='kubernetes-service-endpoints',
  )
)
.addTemplate(
  template.new(
    'node',
    '$PROMETHEUS_DS',
    'label_values(traefik_backend_requests_total, instance)',
    label='Node',
    refresh='time',
    current='10.244.13.245:8080',
  )
)
.addTemplate(
  template.new(
    'protocol',
    '$PROMETHEUS_DS',
    'label_values(traefik_backend_requests_total, protocol)',
    label='Protocol',
    refresh='time',
    current='All',
  )
)
.addTemplate(
  template.interval('interval', 'auto,1m,10m,30m,1h,6h,12h,1d,7d,14d,30d', 'auto')
)
.addRow(
  row.new(
	title='Stats'
    height='275px',
  )
  .addPanel(
    singlestat.new(
      '404 Error Count last $interval',
      format='none',
      datasource='$PROMETHEUS_DS',
      span=2,
      valueName='current',
    )
    .addTarget(
      prometheus.target(
        expr='sum(increase(traefik_backend_requests_total{code="404",method="GET",protocol=~"$protocol"}[$interval]))',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      '$protocol return code',
      span=4,
	  x_axis_mode='series',
	  show_xaxis=false,
	  bars=true,
      format='none',
      fill=0,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=false,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
	  legend_show=false,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='traefik_backend_requests_total{protocol=~"$protocol"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}} : {{code}}',
      )
    )
  )
  .addPanel(
    singlestat.new(
      'Average response time',
      format='ms',
      datasource='$PROMETHEUS_DS',
      span=3,
      valueName='avg',
	  sparklineShow=true,
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_entrypoint_request_duration_seconds_sum) / sum(traefik_entrypoint_requests_total) * 1000',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Average response time',
      span=3,
      format='ms',
      fill=1,
      min=0,
      decimals=2,
      datasource='$PROMETHEUS_DS',
      legend_values=false,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
	  formatY1='ms',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_backend_request_duration_seconds_sum{protocol=~"$protocol"}) / sum(traefik_entrypoint_requests_total{protocol=~"$protocol"}) * 1000',
        datasource='$PROMETHEUS_DS',
        legendFormat='Average Response Time',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Status Code count per $interval',
      span=12,
      format='none',
      fill=1,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
	  formatY1='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(increase(traefik_backend_requests_total{protocol=~"$protocol"}[$interval])) by (code)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{code}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Bad Status Code count per $interval',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(increase(traefik_backend_requests_total{code="404",method="GET",protocol=~"$protocol"}[$interval])) by (backend)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{backend}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Total requests over $interval',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  bars=true,
	  legend_show=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=false,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(rate(traefik_backend_requests_total[$interval]))',
        datasource='$PROMETHEUS_DS',
        legendFormat='Total requests',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Used Sockets',
      span=6,
      format='none',
      fill=1,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,	  
      legend_rightSide=false,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='process_open_fds{job=~"$job"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{ instance }}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Access to Backends',
      span=6,
      format='none',
      fill=1,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=true,
      legend_total=true,
      legend_avg=true,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(rate(traefik_backend_requests_total{protocol=~"http|https",code="200"}[$interval])) by (backend)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{backend}} {{method}} {{code}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Entrypoint - Open Connections',
      span=6,
      format='none',
      fill=7,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
	  stack=true,
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_entrypoint_open_connections) by (method)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Entrypoint - Open Connections',
      span=6,
      format='none',
      fill=7,
      decimals=0,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=false,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
	  stack=true,
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_backend_open_connections) by (method)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}}',
      )
    )
  )
)