# Spigot サーバーをビルドしてデプロイするための Dockerfile (Java 24, 複数プラグイン, ポート変更)

FROM eclipse-temurin:24-jdk-slim

WORKDIR /tmp

RUN apt-get update && apt-get install -y --no-install-recommends wget git \
    && wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

RUN java -jar BuildTools.jar --rev 1.21.4

WORKDIR /server

COPY --from=0 /tmp/spigot-*.jar /server/spigot.jar

RUN echo "eula=true" > /server/eula.txt

# ポート変更
EXPOSE 25566

# プラグインを配置するディレクトリを作成
RUN mkdir -p /server/plugins

# プラグインをコピー (例)  -- ここをカスタマイズ --
# ホスト側の plugins ディレクトリからコンテナ内の /server/plugins へコピーする。
# Dockerfile と同じディレクトリに plugins ディレクトリを作成し、そこに .jar ファイルを配置してください。
COPY plugins/*.jar /server/plugins/


CMD ["java", "-Xms1024M", "-Xmx2048M", "-jar", "spigot.jar", "nogui"]