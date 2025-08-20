FROM nginx:latest
COPY nginx/conf.d/local.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/conf.d/local.conf
