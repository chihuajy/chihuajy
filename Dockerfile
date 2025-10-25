# ИСХОДНЫЙ ОБРАЗ
FROM 9hitste/app:latest

# 1. Установка общих утилит
RUN apt-get update && \
    apt-get install -y wget tar netcat bash && \
    rm -rf /var/lib/apt/lists/*

# 2. Установка порта
ENV PORT 8000
EXPOSE 8000

# 3. КОМАНДА ЗАПУСКА (CMD)
CMD bash -c " \
    # --- ШАГ А: НЕМЕДЛЕННЫЙ ЗАПУСК HEALTH CHECK ---
    # Это должно произойти первым, чтобы удовлетворить таймаут платформы.
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p ${PORT} -q 0 -w 1; done & \
    
    # --- ШАГ Б: ЗАПУСК ОСНОВНОГО СЦЕНАРИЯ И КОНФИГУРАЦИЯ ---
    # Теперь мы запускаем все долгие/зависимые задачи в фоне.
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --session-note=cropused --note=cropused --schedule-reset=1 --cache-del=200 --create-swap=10G & \
    
    # Даем программе время для установки перед копированием конфигов
    sleep 35; \
    
    # Копирование конфигов
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/atrei73/9hits-project/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/9hits-project-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/9hits-project-main && \
    echo 'Копирование конфигурации завершено.'; \
    \
    # --- ШАГ В: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    tail -f /dev/null \
"
