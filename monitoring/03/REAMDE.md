### Домашнее задание к занятию «Система сбора логов Elastic Stack».

Примечание:
Система мониторинга и логгирования - сильно востребованы в моей компании. Часть кода и подходов я перенёс из своего рабочего продакшн окружения, для выполнение этого домашнего задания. Так же я решил не использовать устаревшие версии пакетов и должен признаться, - для внедрения TLS сквозной сертификации локальных нод (которую у меня мозга не хватило самому внедрить), что требует elastic в версиях 8 и 9, я использовал помощь ИИ (на что пришлось потрать много времени). Т.к мне был непонятен пайплайн выпуска, проверки, защиты и сроков каждых конкретных сертификатов, которые требует Google (825 дней, локальные CA до 5 лет, и.т.д), а так же обязательная проверяемая идемпотентность и виртуалное venv окружение. Задание выполнял на своём локальном ПК с Linux Mint, по этому пути в скриптах указаны не универсальные, а валидные для моего домашнего ПК (не трудно их исправить под нужные), это в первую очередеь связано с сертификацией и IDE.

Разделение на 2 скрипта осознаное, `init.sh` настраивает окружение и секреты для второго скрипта. а второй скрипт `elastic.sh` уже используется внутри `docker compose up` для идемпотентности, безопасности, повторяемости.


Описание:
Сначала запускается `sudo /bin/bash /scripts/init.sh /setup/init.sh`
Он подготавливает окружение, создают сертификаты, права, директории, лимиты mmap, .env, и.т.д.

Важно:
```
docker info -f '{{.DockerRootDir}}'
```
Должен вернуть `/var/lib/docker`.
а
```
id -u
```
Должен вернуть `1000`
Потомцу что для `TCP клиента` понадобится `sudo`, а серты пренадлежат `uid 1000`.

<img width="321" height="603" alt="1-3" src="https://github.com/user-attachments/assets/7e554339-3d66-45a7-b2a1-9cb84bd98e51" />


После запуска `docker compose up -d` поднимаются 5 контейнеров.
В `compose.yaml` добавлена ротация логов, иначе они будут расти бесконечно.
Поскольку сертификаты, кредиты и пути уже известны после инициации, то всё должно пройти штатно, однако если сначала запустить `docker compose`, то код упадёт с ошибкой из-за необьявленных переменных (`set -euo pipefail`).

Важно:
`docker.sock` в `Filebeat`  с `:ro` это фактически `root` на хосте, потому-что :ro не ограничивает docker api. Мы в проде используем `socket-proxy` с доступом к get или агента.

`compose` вызывает `elastic.sh` из `setup` директории. конфигурация кластера, обвязка безопасности (пароли, политики) и настраивает шаблон для`logsash`.



---

1.

<img width="2147" height="374" alt="1" src="https://github.com/user-attachments/assets/32378a77-018b-4770-b42f-7c5e05b400ee" />

<img width="2093" height="1339" alt="1-2" src="https://github.com/user-attachments/assets/bd63c77f-6bc0-4bed-8e05-f9bfe281ab38" />

---

2.

<img width="2141" height="329" alt="2" src="https://github.com/user-attachments/assets/904ae621-39d4-4499-ab3d-23be038fe965" />

<img width="994" height="762" alt="2-2" src="https://github.com/user-attachments/assets/e8c3d234-5fc1-44d9-8810-6f16497170d3" />

<img width="2554" height="1123" alt="2-3" src="https://github.com/user-attachments/assets/3c0ed91c-82e6-428d-ae65-261641d1ad8a" />

<img width="2552" height="1415" alt="2-4" src="https://github.com/user-attachments/assets/71fa25f4-a7c0-4642-9a47-5253bb2ebb21" />

<img width="624" height="764" alt="2-5" src="https://github.com/user-attachments/assets/3513715d-2876-4e26-95a7-656ef8501a45" />

<img width="1548" height="990" alt="2-6" src="https://github.com/user-attachments/assets/787f6f06-9428-4c81-a42a-3e191c21148d" />

<img width="2555" height="1272" alt="2-7" src="https://github.com/user-attachments/assets/f468ada5-d985-4adc-8b4f-271acb072a71" />

<img width="1471" height="745" alt="2-8" src="https://github.com/user-attachments/assets/d4051e6b-0d29-4948-a5e2-1746c46e634e" />

<img width="1495" height="839" alt="2-9" src="https://github.com/user-attachments/assets/096141cc-12dd-4261-a3c5-89dfde7432cd" />

<img width="1390" height="896" alt="2-10" src="https://github.com/user-attachments/assets/0a626c7c-8c32-45a1-8468-30a5cdf0cf17" />

<img width="723" height="415" alt="2-11" src="https://github.com/user-attachments/assets/5941d7c9-fd5f-4f72-8680-68ba3bd173da" />

---
---
