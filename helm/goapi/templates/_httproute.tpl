{{ define "goapi.httproute" }}
{{- if .Values.ingress.enabled -}}
{{- $root := . -}}
{{- range $host := .Values.ingress.hosts }}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "goapi.fullname" $root }}
  namespace: {{ $root.Values.namespace }}
spec:
  hostnames: [{{ $host.host }}]
  parentRefs:
  - name: gateway
    namespace: istio-ingress
  rules:
  - matches:
    {{- range $path := $host.paths }}
    - path:
        type: {{ $path.pathType }}
        value: {{ $path.path }}
    {{- end }}
    backendRefs:
    - name: {{ include "goapi.fullname" $root }}
      port: 80
---
{{- end -}}
{{- end -}}
{{- end -}}
