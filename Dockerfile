FROM ubuntu:24.04

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
       ca-certificates bash curl dos2unix iptables redsocks libc6 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -A "Mozilla/5.0" https://wizardgain.com/download/wizardgain-linux -o /app/WizardGain \
    && chmod +x /app/WizardGain

COPY entrypoint.sh /app/entrypoint.sh

RUN dos2unix /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh /app/WizardGain

ENTRYPOINT ["/app/entrypoint.sh"]
