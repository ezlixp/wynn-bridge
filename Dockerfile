FROM node:22 AS base
WORKDIR /usr/local/app

FROM base AS backend-base
COPY ico_server/package.json ico_server/package-lock.json ./
COPY ico_server/.env.production ./
COPY ico_server/jest.config.json ico_server/tsconfig.json ./
COPY ico_server/src ./src
COPY ico_server/test ./test
RUN npm install

FROM backend-base AS backend-dev
CMD ["npm", "run", "dev"]

FROM backend-dev AS test
RUN npm run test

FROM backend-base AS backend-final
ENV NODE_ENV=production
RUN npm ci --production && npm cache clean --force
EXPOSE 3000
CMD ["npx", "tsx", "src/index.ts"]

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


