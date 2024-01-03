{{ define "goapi.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "goapi.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "goapi.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: 80
      targetPort: {{ .Values.service.port }}
      protocol: TCP
      name: http
  selector:
    {{- include "goapi.selectorLabels" . | nindent 4 }}
{{- end }}