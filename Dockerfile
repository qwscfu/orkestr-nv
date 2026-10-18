FROM node:24-bookworm-slim AS deps

WORKDIR /tmp

RUN apt-get update && apt-get install -y --no-install-recommends \
        make \
        python3 \
        g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY package.json ./
RUN npm install

FROM node:24-bookworm-slim

WORKDIR /tmp

COPY index.js index.html ./
COPY --from=deps /tmp/node_modules ./node_modules

EXPOSE 3000/tcp

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssl \
        curl \
        iproute2 \
        coreutils \
        bash \
        iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x index.js

HEALTHCHECK --interval=60s --timeout=5s --start-period=90s \
    CMD node -e "require('http').get('http://127.0.0.1:'+(process.env.PORT||3000)+'/'+(process.env.SUB_PATH||'sub'),r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "index.js"]
