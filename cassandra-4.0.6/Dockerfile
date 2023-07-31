FROM library/cassandra:4.0.6

COPY ./cassandra.yaml /etc/cassandra/cassandra.yaml
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-command.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "docker-command.sh" ]