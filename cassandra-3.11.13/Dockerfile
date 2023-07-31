FROM library/cassandra:3.11.13

COPY ./cassandra.yaml /etc/cassandra/cassandra.yaml
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-command.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "docker-command.sh" ]
