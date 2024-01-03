{{ define "goapi.secret" }}
{{- if .Values.secret -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secret
  namespace: {{ .Values.namespace }}
type: {{ .Values.secret.type }}
{{- if .Values.secret.enabled }}
data:
  {{- range $key, $value := .Values.secret.data }}
  {{ $key }}: {{ $value | b64enc | quote }}
  {{- end }}
{{- end -}}
{{- end -}}
{{- end -}}