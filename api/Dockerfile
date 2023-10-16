FROM python:3.11.3-slim AS build
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt

FROM python:3.11.3-slim
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=build /opt/venv /opt/venv
ADD app.py .
EXPOSE 8080
CMD [ "python", "app.py"]