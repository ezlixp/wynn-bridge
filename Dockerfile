FROM node:22-slim AS base
WORKDIR /usr/local/app

FROM base AS backend-deps
COPY ico_server/package*.json ./
RUN npm ci

# TODO: use env injection
FROM backend-deps AS backend-build
COPY ico_server/tsconfig.json ./
COPY ico_server/.env.* ./
COPY ico_server/src ./src
RUN npx tsc

FROM backend-build AS backend-test
COPY ico_server/jest.config.json ./
COPY ico_server/test ./test
RUN npm test

FROM base AS backend-prod-deps
COPY ico_server/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force


FROM backend-build AS backend-dev
CMD ["npm", "run", "dev"]

FROM node:22-slim AS backend-final
WORKDIR /usr/local/app
ENV NODE_ENV=production

COPY --from=backend-prod-deps /usr/local/app/node_modules ./node_modules
COPY --from=backend-build /usr/local/app/dist/src ./dist
COPY ico_server/.env.production ./

EXPOSE 3000
CMD ["node", "dist/index.js"]

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS bot-runtime
WORKDIR /usr/local/bot

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS bot-build
WORKDIR /usr/local/bot
COPY ogybot_discord/ ./
RUN dotnet restore ./ogybot.Bot/ogybot.Bot.csproj
RUN dotnet build ogybot.Bot/ogybot.Bot.csproj -c Release -o /usr/local/bot/build
RUN dotnet publish ogybot.Bot/ogybot.Bot.csproj -c Release -o /usr/local/bot/publish --no-restore

FROM bot-runtime AS bot-final
COPY --from=bot-build /usr/local/bot/publish ./
CMD ["dotnet", "ogybot.Bot.dll"]


