local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;

grafana.dashboard.new(
  'Traefik By Endpoint-Dashboard',
  refresh='1m',
  uid='aGqZLJemk',
  time_from='now-60m',
  editable=true,
  tags=['P360', 'Traefik'],
  description='Traefik By Endpoint-Dashboard',
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
    'backend',
    '$PROMETHEUS_DS',
    'label_values(backend)',
    label='Backend',
    refresh='time',
    current='/api/pdr',
  )
)
.addTemplate(
  template.new(
    'entrypoint',
    '$PROMETHEUS_DS',
    'label_values(entrypoint)',
    label='Entrypoint',
    refresh='time',
    includeAll=true,
    multi=true,
    current='All',
  )
)
.addRow(
  row.new(
	title='$backend stats',
    height='275px',
  )
  .addPanel(
    singlestat.new(
      '$backend status',
      format='none',
      datasource='$PROMETHEUS_DS',
      span=3,
      valueName='current',
	  thresholds='0,1',
      colorValue=true,
	  valueMaps=[
		{
		  value: '1',
		  op: '=',
		  text: 'OK',
	    },
		{
		  value: '0',
		  op: '=',
		  text: 'DOWN',
	    },
	  ],
    colors=[
      '#d44a3a',
      'rgba(237, 129, 40, 0.89)',
      '#299c46',
    ],
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_backend_server_up{backend="$backend"})/count(traefik_config_reloads_total)',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      '$backend return code',
      span=6,
	  x_axis_mode='series',
	  show_xaxis=false,
	  bars=true,
      format='none',
      fill=0,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=true,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=false,
	  legend_show=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='traefik_backend_requests_total{backend="$backend"}',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}} : {{code}}',
      )
    )
  )
  .addPanel(
    singlestat.new(
      '$backend response time',
      format='ms',
      datasource='$PROMETHEUS_DS',
      span=3,
      valueName='avg',
	  sparklineShow=true,
    )
    .addTarget(
      prometheus.target(
        expr='sum(traefik_backend_request_duration_seconds_sum{backend="$backend"}) / sum(traefik_backend_requests_total{backend="$backend"}) * 1000',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Total requests over 5min $backend',
      span=12,
      format='none',
      fill=1,
      min=0,
      decimals=0,
	  bars=true,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=false,
      legend_total=false,
      legend_avg=true,
      legend_alignAsTable=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(rate(traefik_backend_requests_total{backend="$backend"}[5m]))',
        datasource='$PROMETHEUS_DS',
        legendFormat='Total requests $backend',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Status code 200 over 5min',
      span=6,
      format='none',
      fill=0,
      min=0,
      decimals=0,
	  bars=true,
      datasource='$PROMETHEUS_DS',
	  legend_show=true,
      legend_values=true,
      legend_min=true,
      legend_max=true,
      legend_current=true,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
	  formatY2='short',
	  stack=true,
    )
    .addTarget(
      prometheus.target(
        expr='rate(traefik_entrypoint_requests_total{entrypoint=~"$entrypoint",code="200"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{method}} : {{code}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Others status code over 5min',
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
      legend_current=true,
      legend_total=false,
      legend_avg=false,
      legend_alignAsTable=true,	  
      legend_rightSide=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='rate(traefik_entrypoint_requests_total{entrypoint=~"$entrypoint",code!="200"}[5m])',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{ method }} : {{code}}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Requests by service',
      span=6,
	  x_axis_mode='series',
	  show_xaxis=false,
	  bars=true,
      format='none',
      fill=0,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=true,
      legend_avg=false,
      legend_alignAsTable=false,
	  legend_show=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(rate(traefik_backend_requests_total[5m])) by (backend)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{ backend }}',
      )
    )
  )
  .addPanel(
    graphPanel.new(
      'Requests by protocol',
      span=6,
	  x_axis_mode='series',
	  show_xaxis=false,
	  bars=true,
      format='none',
      fill=0,
      min=0,
      decimals=0,
      datasource='$PROMETHEUS_DS',
      legend_values=true,
      legend_min=false,
      legend_max=false,
      legend_current=false,
      legend_total=true,
      legend_avg=false,
      legend_alignAsTable=false,
	  legend_show=true,
	  formatY1='short',
	  formatY2='short',
    )
    .addTarget(
      prometheus.target(
        expr='sum(rate(traefik_entrypoint_requests_total{entrypoint =~ "$entrypoint"}[5m])) by (entrypoint)',
        datasource='$PROMETHEUS_DS',
        legendFormat='{{ entrypoint }}',
      )
    )
  )
)