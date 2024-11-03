# Instalacja

1. Dodaj poniższy fragment konfiguracji do `/config/configuration.yaml`:
```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 0.0.0.0/0
```

2. Zaznacz opcję __Uruchamianie przy starcie__
3. Przejdź do Konfiguracji i uzupełnij potrzebne dane
4. Uruchom dodatek 
