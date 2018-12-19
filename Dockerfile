FROM python:slim-stretch
MAINTAINER Shane Frasier <jeremy.frasier@beta.dhs.gov>

# Install git so we can checkout the domain-scan git repo.
#
# Install redis to we can use redis-cli to communicate with redis.
#
# Finally, we need wget to pull the latest list of Federal domains
# from GitHub.
RUN apt-get --quiet update \
    && apt-get install --quiet --assume-yes \
    git \
    redis-tools \
    wget

# Create unprivileged user
ENV GATHERER_HOME=/home/gatherer
RUN mkdir ${GATHERER_HOME} \
    && addgroup --system gatherer \
    && adduser --system --gecos "Gatherer user" --group gatherer \
    && chown -R gatherer:gatherer ${GATHERER_HOME}

# Clean up aptitude cruft
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Put this just before we change users because the copy (and every
# step after it) will often be rerun by docker, but we need to be root
# for the chown command.
COPY . $GATHERER_HOME
RUN chown -R gatherer:gatherer ${GATHERER_HOME}

###
# Prepare to Run
###
# USER gatherer:gatherer
WORKDIR $GATHERER_HOME
ENTRYPOINT ["./gather-domains.sh"]
