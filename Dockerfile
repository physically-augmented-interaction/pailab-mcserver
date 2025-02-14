FROM eclipse-temurin:24-jdk-slim

# BuildTools のための作業ディレクトリ
WORKDIR /tmp

# 必要なツールをインストール (wget, git)
RUN apt-get update && apt-get install -y --no-install-recommends wget git

# BuildTools.jar をダウンロード
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

# BuildTools を実行して Spigot をビルド (バージョンは必要に応じて変更)
RUN java -jar BuildTools.jar --rev 1.21.4

# サーバーファイルを配置する作業ディレクトリ
WORKDIR /server

# ビルドされた Spigot サーバーをコピー
COPY --from=0 /tmp/spigot-*.jar /server/spigot.jar

# eula.txt を作成
RUN echo "eula=true" > /server/eula.txt

# Minecraft サーバーのポートを開放
EXPOSE 25566

# 設定ファイルとプラグインを配置するための Git リポジトリを clone
RUN git clone --depth 1 -b main https://github.com/physically-augmented-interaction/pailab-mcserver.git /tmp/config

# server.properties をコピー
COPY --from=0 /tmp/config/server.properties /server/server.properties
RUN echo "rcon.password=YOUR_PASSWORD" >> /server/server.properties

# plugins ディレクトリをコピー
COPY --from=0 /tmp/config/plugins /server/plugins
RUN echo "BotToken: ''" >> /server/plugins/DiscordSRV/config.yml
RUN echo "Channels: { 'global': '' }" >> /server/plugins/DiscordSRV/config.yml
RUN echo "DiscordConsoleChannelId: ''" >> /server/plugins/DiscordSRV/config.yml

# Spigot サーバーを起動
CMD ["java", "-Xms2G", "-Xmx4G", "-jar", "spigot.jar", "nogui"]