{{ define "goapi.serviceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "goapi.serviceAccountName" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "goapi.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ .Values.serviceAccount.automount }}
{{- end }}
