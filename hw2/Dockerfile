# Use a Node.js base image
FROM node

# Set working directory /usr/src/app as an environment variable
WORKDIR /usr/src/app

# Copy package.json and server.js over to image
COPY package.json server.js ./

# Install dependencies
RUN npm install

# EXPOSE port 3030 from the container
EXPOSE 3030

# Run npm start at container start time
CMD ["npm", "start"]


#docker build -t hw2_image .
#docker run --name="hw2_cont" -p 5000:3030 -d hw2_image