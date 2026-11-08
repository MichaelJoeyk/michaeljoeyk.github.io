# Testumgebung: Startseite + vier Apps auf http://<IP>:8090/
test:
    ./testenv.sh

test-status:
    ./testenv.sh status

test-stop:
    ./testenv.sh down
