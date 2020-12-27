FROM node:12
# docker build -t sourcecred .

# Set up working directory.
RUN mkdir -p /code
WORKDIR /code

# Install global and local dependencies first so they can be cached.
RUN npm install -gf yarn@^1.21.1
COPY package.json yarn.lock /code/
RUN yarn


#Istall pm2 to start proccess on the background
RUN yarn global add pm2


# Declare data directory.
ARG SOURCECRED_DEFAULT_DIRECTORY=/data
ENV SOURCECRED_DIRECTORY ${SOURCECRED_DEFAULT_DIRECTORY}

# Install the remainder of our code.
COPY . /code
#RUN yarn start
# RUN pm2 start yarn --name sourcecred -- start
EXPOSE 6006

CMD ["yarn", "start" ]

# ENTRYPOINT ["/bin/bash pm2 start yarn --name sourcecred -- start"]