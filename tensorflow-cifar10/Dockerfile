FROM alexmilowski/cuda9-py36:latest

RUN mkdir /data /app /train
COPY *.py /app/
COPY app.sh /app/

WORKDIR /app
ENTRYPOINT ["/app/app.sh"]

# example arguments: --data_dir=/data --train_dir=/train
