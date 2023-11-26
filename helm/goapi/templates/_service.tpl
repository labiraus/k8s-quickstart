{{ define "goapi.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "goapi.fullname" . }}
  labels:
    {{- include "goapi.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
  selector:
    {{- include "goapi.selectorLabels" . | nindent 4 }}
{{- end }}