{{/*
Expand the name of the chart.
*/}}
{{- define "u-assist-promise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "u-assist-promise.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "u-assist-promise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "u-assist-promise.labels" -}}
helm.sh/chart: {{ include "u-assist-promise.chart" . }}
{{ include "u-assist-promise.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "u-assist-promise.selectorLabels" -}}
app.kubernetes.io/name: {{ include "u-assist-promise.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "u-assist-promise.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "u-assist-promise.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "u-assist-promise.ingress.annotations" -}}
{{- if ne .Values.ingress.domainName "localhost" -}}
ingress.kubernetes.io/force-ssl-redirect: "true"
{{- end }}
{{- end }}

{{- define "u-assist-promise.ingress.tls" -}}
{{- if ne .Values.ingress.domainName "localhost" -}}
{{- if .Values.ingress.host }}
tls:
  - hosts:
      - {{ .Values.ingress.host }}
    {{- if contains ".staging." .Values.ingress.host }}
    secretName: {{ .Values.ingress.wildcardCert.certStaging }}
    {{- else }}
    secretName: {{ .Values.ingress.tls.secretName }}
    {{- end }}
{{- else }}
tls:
  - hosts:
      - {{ .Values.ingress.hostName }}.{{ .Values.ingress.domainName }}
    secretName: {{ .Values.ingress.certName }}
{{- end }}
{{- end }}
{{- end }}
