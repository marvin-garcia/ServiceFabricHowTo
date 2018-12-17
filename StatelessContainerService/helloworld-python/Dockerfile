# Use an official Python runtime as a base image
FROM python:2.7-windowsservercore

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Copy the required files
COPY PersistAzureFileCredentials.ps1 /app/PersistAzureFileCredentials.ps1

# Persistently save Azure files credentials
# Make sure to replace the values for <storage-account-name> and <storage-account-key>
RUN powershell.exe .\PersistAzureFileCredentials.ps1 -FileShareEndPointHost <storage-account-name>.file.core.windows.net -StorageAccountName <storage-account-name> -StorageAccountKey <storage-account-key>

# Mount network drive in the container
# Make sure to replace the values for <storage-account-name> and <file-share-name>
RUN net use Z: \\<storage-account-name>.file.core.windows.net\<file-share-name> /persistent:yes

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app.py when the container launches
# Make sure to replace the values for <storage-account-name> and <file-share-name>
CMD python app.py \\<storage-account-name>.file.core.windows.net\<file-share-name>