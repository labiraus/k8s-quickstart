{{- define "goapi.manifest" -}}
{{- include "goapi.deployment" . }}
---
{{- include "goapi.serviceAccount" . }}
---
{{- include "goapi.service" . }}
---
{{- include "goapi.secret" . }}
---
{{- include "goapi.configmap" . }}
---
{{- include "goapi.poddisruptionbudget" . }}
---
{{- include "goapi.hpa" . }}
---
{{- include "goapi.httproute" .}}
{{- end}}
