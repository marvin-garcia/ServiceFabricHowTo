# Use an official Python runtime as a base image
FROM python:2.7-windowsservercore

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Copy the PS script to map the network drive
# COPY MountNetworkDrive.ps1 /app/MountNetworkDrive.ps1

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Mount network drive in the container
RUN ["net.exe", "use", "Z:", "\\servicefabric3storage.file.core.windows.net\fileshare", "/u:AZURE\servicefabric3storage", "6JCcMiMQl1xP65mhGuPbU/wXeoak6MJZ7dtyFg5I7jdoAdQhmjq5LNYTqqQiGBFA4qubnWWDZcIGoGSsJ60xQg=="]

# Run app.py when the container launches
CMD ["python", "app.py"]