# Start with a very light Nginx image
FROM nginx:alpine

# Install Git to clone the source repository
RUN apk add --no-cache git

# Define where the application will live inside the container
WORKDIR /usr/share/nginx/html

# *** ADD THIS LINE TO CLEAR THE DIRECTORY BEFORE CLONING ***
RUN rm -rf ./* || true # Remove all contents, || true prevents error if directory is already empty

# Clone the source repository directly into the Nginx web root
# This repo contains your index.html and static files
RUN git clone https://github.com/sriram-R-krishnan/devops-build.git .

# ... after git clone .
RUN mv /usr/share/nginx/html/build/* /usr/share/nginx/html/ && rm -r /usr/share/nginx/html/build
# ...

# Copy your Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for web traffic
EXPOSE 80

# Command to start Nginx
CMD ["nginx", "-g", "daemon off;"]
