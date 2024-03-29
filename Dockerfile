# Base image: ubuntu:22.04
FROM ubuntu:22.04

# ARGs
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG TARGETPLATFORM=linux/amd64,linux/arm64
ARG DEBIAN_FRONTEND=noninteractive
ARG TOKEN=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

# neo4j 5.5.0 installation and some cleanup
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' > /etc/apt/sources.list.d/neo4j.list && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y nano unzip neo4j=1:5.5.0 python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# TODO: Complete the Dockerfile
# install git
RUN apt-get update && \
    apt-get install -y git
RUN apt-get install -y curl

RUN mkdir /cse511
#RUN cd cse511

#clone repo
RUN git clone https://$TOKEN@github.com/CSE511-SPRING-2023/ardeshp4-project-2.git /cse511/

RUN curl -o /cse511/yellow_tripdata_2022-03.parquet https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-03.parquet

RUN cd cse511

#install libraries
RUN python3 -m pip install --upgrade pip
RUN pip install neo4j
RUN pip install pandas
RUN pip install pyarrow
RUN sed -i 's/#server.default_listen_address=0.0.0.0/server.default_listen_address=0.0.0.0/g' /etc/neo4j/neo4j.conf
RUN bin/neo4j-admin dbms set-initial-password project2phase1

WORKDIR /cse511
# Run the data loader script
RUN chmod +x /cse511/data_loader.py && \
    neo4j start && \
    python3 data_loader.py && \
    neo4j stop


#Install neo4j plugin
RUN curl -o /cse511/neo4j-graph-data-science-2.3.1.zip https://graphdatascience.ninja/neo4j-graph-data-science-2.3.1.zip
RUN unzip /cse511/neo4j-graph-data-science-2.3.1.zip -d /cse511/
RUN mv /cse511/neo4j-graph-data-science-2.3.1.jar /var/lib/neo4j/plugins/

# Set security procedures in neo4j.conf
RUN echo "dbms.security.procedures.unrestricted=gds.*" >> /etc/neo4j/neo4j.conf
RUN sed -i '/dbms.security.procedures.whitelist/c\dbms.security.procedures.whitelist=gds\.\*' /etc/neo4j/neo4j.conf
RUN echo "dbms.security.procedures.allowlist=gds.*" >> /etc/neo4j/neo4j.conf
RUN echo "dbms.directories.plugins=/var/lib/neo4j/plugins/" >> /etc/neo4j/neo4j.conf

# Expose neo4j ports
EXPOSE 7474 7687

# Start neo4j service and show the logs on container run
CMD ["/bin/bash", "-c", "neo4j start && tail -f /dev/null"]
