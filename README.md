Resource Explorer
================

Fork of [kube-resource-explorer](https://github.com/dpetzold/kube-resource-explorer) by dpetzold 
## My Changes
- updated modules and go version
- fixed kube handling
- parse multiple kubeconfigs in one path (eg.: path/to/config1:path/to/config2)
- removed vendor folder (maybe just because i don't understand the use of it)
- add binary releases

Explore your kube resource usage and allocation.

* Display historical statistical resource usage from StackDriver.

  https://github.com/kubernetes/kubernetes/issues/55046

* List resource QoS allocation to pods in a cluster. Inspired by:

  https://github.com/kubernetes/kubernetes/issues/17512


## Usage

## Command Line Options                                                                                                
* `-namespace` - Limit the query to the specified namespace (defaults to all)
* `-sort` - Field to sort by
* `-reverse` - Reserve the sort order
* `-historical` - Display historical resource data
* `-cpu` - Show historical cpu data
* `-mem` - Show historical memory data
* `-duration` - The duration to use for historical data (default to 4h)
* `-project` - The GCloud project id (required for historical)
* `-workers` - Number of workers to run for historical
* `-csv` - Export results to CSV file

To use the historical functionality you must set the
`GOOGLE_APPLICATION_CREDENTIALS` environment variable. See below for more
information:

https://cloud.google.com/monitoring/docs/reference/libraries


## Run
```
docker run -it \
    -v${HOME}/.kube:/.kube \
    -v${HOME}/.config/gcloud:/.config/gcloud \
    -v/etc/ssl/certs:/etc/ssl/certs \
    dpetzold/kube-resource-explorer
```

## Build
```
go get github.com/dpetzold/kube-resource-explorer/cmd/kube-resource-explorer
```

## Example output

Show aggregate resource requests and limits. This is the same information
displayed by `kubectl describe nodes` but in a easier to view format. 

```
$ kube-resource-explorer -namespace kube-system -reverse -sort MemReq
Namespace    Name                                                              CpuReq       CpuReq%  CpuLimit    CpuLimit%  MemReq         MemReq%  MemLimit       MemLimit%
---------    ----                                                              ------       -------  --------    ---------  ------         -------  --------       ---------
kube-system  kube-proxy-gke-project-default-pool-175a4a05-bv59/kube-proxy      100m         10%      0m          0%         0Mi            0%       0Mi            0%
kube-system  event-exporter-v0.1.7-5c4d9556cf-kf4tf/prometheus-to-sd-exporter  0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  fluentd-gcp-v2.0.9-jmtpw/prometheus-to-sd-exporter                0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  fluentd-gcp-v2.0.9-4qkwk/prometheus-to-sd-exporter                0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  kube-proxy-gke-project-default-pool-175a4a05-mshh/kube-proxy      100m         10%      0m          0%         0Mi            0%       0Mi            0%
kube-system  heapster-v1.4.3-74b5bd94bb-fz8hd/prom-to-sd                       0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  fluentd-gcp-v2.0.9-tw9vk/prometheus-to-sd-exporter                0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  event-exporter-v0.1.7-5c4d9556cf-kf4tf/event-exporter             0m           0%       0m          0%         0Mi            0%       0Mi            0%
kube-system  kube-proxy-gke-project-default-pool-175a4a05-ntfw/kube-proxy      100m         10%      0m          0%         0Mi            0%       0Mi            0%
kube-system  kube-dns-autoscaler-244676396-xzgs4/autoscaler                    20m          2%       0m          0%         10Mi           0%       0Mi            0%
kube-system  kube-dns-323615064-8nxfl/sidecar                                  10m          1%       0m          0%         20Mi           0%       0Mi            0%
kube-system  kube-dns-323615064-8nxfl/dnsmasq                                  150m         15%      0m          0%         20Mi           0%       0Mi            0%
kube-system  l7-default-backend-1044750973-kqh98/default-http-backend          10m          1%       10m         1%         20Mi           0%       20Mi           0%
kube-system  kube-dns-323615064-8nxfl/kubedns                                  100m         10%      0m          0%         70Mi           2%       170Mi          6%
kube-system  heapster-v1.4.3-74b5bd94bb-fz8hd/heapster-nanny                   50m          5%       50m         5%         90Mi           3%       90Mi           3%
kube-system  kubernetes-dashboard-768854d6dc-jh292/kubernetes-dashboard        100m         10%      100m        10%        100Mi          3%       300Mi          11%
kube-system  fluentd-gcp-v2.0.9-jmtpw/fluentd-gcp                              100m         10%      0m          0%         200Mi          7%       300Mi          11%
kube-system  fluentd-gcp-v2.0.9-tw9vk/fluentd-gcp                              100m         10%      0m          0%         200Mi          7%       300Mi          11%
kube-system  fluentd-gcp-v2.0.9-4qkwk/fluentd-gcp                              100m         10%      0m          0%         200Mi          7%       300Mi          11%
kube-system  heapster-v1.4.3-74b5bd94bb-fz8hd/heapster                         88m          9%       88m         9%         204Mi          7%       204Mi          7%
---------    ----                                                              ------       -------  --------    ---------  ------         -------  --------       ---------
Total                                                                          1128m/2820m  40%      248m/2820m  8%         1134Mi/7936Mi  14%      1684Mi/7936Mi  21%
```

Display historical statistical resource usage from StackDriver. This will
evaluate the TimeSeries data from StackDriver and show the latest value (the
most current data point), minimum value, maximum value and the average or the
mode in the requested duration per container. The average is displayed when
cpu is requested. For memory the mode is displayed (mode is the most common
occurring value in the set).

```
$ kube-resource-explorer -historical -duration 4h -mem -sort MemoryMode -reverse -namespace kube-system -project myprojectid
Pod/Container                                                     Last    Min     Max     Mode
-------------------------------------------------------------     ------  ------  ------  --------
l7-default-backend-1044750973-kqh98/default-http-backend          2Mi     2Mi     2Mi     2Mi
kube-dns-323615064-8nxfl/dnsmasq                                  6Mi     6Mi     6Mi     6Mi
event-exporter-v0.1.7-5c4d9556cf-kf4tf/prometheus-to-sd-exporter  6Mi     6Mi     6Mi     6Mi
heapster-v1.4.3-74b5bd94bb-fz8hd/prom-to-sd                       7Mi     7Mi     7Mi     7Mi
fluentd-gcp-v2.0.9-4qkwk/prometheus-to-sd-exporter                8Mi     8Mi     8Mi     8Mi
fluentd-gcp-v2.0.9-tw9vk/prometheus-to-sd-exporter                9Mi     9Mi     9Mi     9Mi
fluentd-gcp-v2.0.9-jmtpw/prometheus-to-sd-exporter                9Mi     9Mi     9Mi     9Mi
kube-dns-323615064-8nxfl/kubedns                                  10Mi    10Mi    10Mi    10Mi
heapster-v1.4.3-74b5bd94bb-fz8hd/heapster-nanny                   10Mi    10Mi    10Mi    10Mi
kube-dns-autoscaler-244676396-xzgs4/autoscaler                    11Mi    11Mi    11Mi    11Mi
kube-dns-323615064-8nxfl/sidecar                                  13Mi    12Mi    13Mi    13Mi
kube-proxy-gke-project-default-pool-175a4a05-bv59/kube-proxy      15Mi    15Mi    15Mi    15Mi
event-exporter-v0.1.7-5c4d9556cf-kf4tf/event-exporter             15Mi    15Mi    15Mi    15Mi
kube-proxy-gke-project-default-pool-175a4a05-ntfw/kube-proxy      18Mi    18Mi    18Mi    18Mi
kube-proxy-gke-project-default-pool-175a4a05-mshh/kube-proxy      18Mi    18Mi    19Mi    18Mi
kubernetes-dashboard-768854d6dc-jh292/kubernetes-dashboard        31Mi    31Mi    31Mi    31Mi
heapster-v1.4.3-74b5bd94bb-fz8hd/heapster                         33Mi    32Mi    39Mi    34Mi
fluentd-gcp-v2.0.9-jmtpw/fluentd-gcp                              138Mi   136Mi   139Mi   138Mi
fluentd-gcp-v2.0.9-tw9vk/fluentd-gcp                              136Mi   130Mi   162Mi   162Mi
fluentd-gcp-v2.0.9-4qkwk/fluentd-gcp                              144Mi   126Mi   181Mi   178Mi

Results shown are for a period of 4h0m0s. 2,400 data points were evaluted.
```

```
$ kube-resource-explorer -historical -duration 4h -cpu -sort CpuMax -reverse -namespace kube-system -project myproj
ectid
Pod/Container                                                     Last    Min     Max     Avg
-------------------------------------------------------------     ------  ------  ------  --------                                     
heapster-v1.4.3-74b5bd94bb-fz8hd/prom-to-sd                       0m      0m      0m      0m                                           
event-exporter-v0.1.7-5c4d9556cf-kf4tf/prometheus-to-sd-exporter  0m      0m      0m      0m                                           
fluentd-gcp-v2.0.9-jmtpw/prometheus-to-sd-exporter                0m      0m      0m      0m                                           
fluentd-gcp-v2.0.9-4qkwk/prometheus-to-sd-exporter                0m      0m      0m      0m                                           
kube-dns-323615064-8nxfl/kubedns                                  0m      0m      0m      0m                                           
kube-dns-323615064-8nxfl/dnsmasq                                  0m      0m      0m      0m                                           
kubernetes-dashboard-768854d6dc-jh292/kubernetes-dashboard        0m      0m      0m      0m                                           
kube-dns-autoscaler-244676396-xzgs4/autoscaler                    0m      0m      0m      0m                                           
l7-default-backend-1044750973-kqh98/default-http-backend          0m      0m      0m      0m                                           
heapster-v1.4.3-74b5bd94bb-fz8hd/heapster-nanny                   0m      0m      0m      0m                                           
fluentd-gcp-v2.0.9-tw9vk/prometheus-to-sd-exporter                0m      0m      0m      0m                                           
event-exporter-v0.1.7-5c4d9556cf-kf4tf/event-exporter             0m      0m      0m      0m                                           
heapster-v1.4.3-74b5bd94bb-fz8hd/heapster                         1m      1m      1m      1m                                           
kube-dns-323615064-8nxfl/sidecar                                  1m      0m      1m      0m                                           
kube-proxy-gke-project-default-pool-175a4a05-ntfw/kube-proxy      1m      1m      2m      1m                                           
kube-proxy-gke-project-default-pool-175a4a05-bv59/kube-proxy      1m      1m      2m      1m                                           
kube-proxy-gke-project-default-pool-175a4a05-mshh/kube-proxy      1m      1m      2m      1m                                           
fluentd-gcp-v2.0.9-tw9vk/fluentd-gcp                              6m      5m      7m      5m                                           
fluentd-gcp-v2.0.9-4qkwk/fluentd-gcp                              6m      5m      12m     6m                                           
fluentd-gcp-v2.0.9-jmtpw/fluentd-gcp                              28m     23m     32m     28m                                          

Results shown are for a period of 4h0m0s. 2,400 data points were evaluted.                                                             
```
