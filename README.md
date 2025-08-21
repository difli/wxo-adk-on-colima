# IBM watsonx Orchestrate ADK on Colima

This project provides a simple, one-step installation script to set up and run the IBM watsonx Orchestrate Agent Development Kit (ADK) on macOS using **Colima** as a fast, stable, and resource-efficient container runtime.

## Overview

The official [IBM watsonx Orchestrate ADK repository](https://github.com/IBM/ibm-watsonx-orchestrate-adk/tree/main) recommends using **Colima** or **Rancher Desktop** as the container runtime for local development. This project provides a streamlined setup specifically for Colima on macOS, aligning with IBM's best practices.

The `install.sh` script automates the following:
1.  **Prerequisite Checks**: Verifies and installs Homebrew, Colima, the Docker CLI, and Python 3.11.
2.  **Colima Machine Configuration**: Initializes or starts a Colima virtual machine with the recommended settings for the ADK (8 CPUs, 16 GB RAM, VZ hypervisor, VirtioFS).
3.  **Python Environment**: Sets up a local Python virtual environment (`.venv`) with the `ibm-watsonx-orchestrate` package.
4.  **Sanity Checks**: Confirms that the container runtime and `orchestrate` CLI are functioning correctly.

## System Requirements

Ensure your macOS system meets the following minimum requirements:

*   **CPU**: 8 cores or more
*   **Memory (RAM)**: 16 GB
*   **Disk Space**: 60 GB of free space for the Colima machine and container images.

## Quick Start

1.  **Clone the Repository**
    ```sh
    git clone <repository-url>
    cd wxo-adk-on-colima
    ```

2.  **Make the script executable**
    ```sh
    chmod +x install.sh
    ```

3.  **Run the Installer**
    ```sh
    ./install.sh
    ```
    The script will check for prerequisites, install them if missing, and configure the Colima VM. This may take several minutes on the first run.

## After Installation

Once the script completes successfully, follow these steps to start the ADK server.

1.  **Configure Environment Variables**

    Copy the example `.env` file. You must add your **Entitlement Key** to run the local server.
    ```sh
    cp .env.example .env
    ```
    Now, open `.env` in your favorite editor. At a minimum, you must provide the `WO_ENTITLEMENT_KEY`. The other keys are for connecting your agents to a watsonx.ai LLM.
    ```ini
    # .env

    # Required to start the local server
    WO_ENTITLEMENT_KEY="your-entitlement-key-goes-here"

    # Required for agents to use watsonx.ai
    WATSONX_APIKEY="your-watsonx-api-key-goes-here"
    WATSONX_SPACE_ID="your-watsonx-space-id-goes-here"
    ```

2.  **Activate the Python Environment**

    Before running any `orchestrate` commands, you must activate the virtual environment created by the script:
    ```sh
    source .venv/bin/activate
    ```
    Your shell prompt should now be prefixed with `(.venv)`.

3.  **Start the Developer Stack**

    With your environment activated, start the local server, telling it to load your key from the `.env` file.
    ```sh
    orchestrate server start -e .env
    ```
    This command will pull over a dozen container images and start the developer services. The first run will take several minutes.

4.  **Activate Environment and Start Chat**

    Once the server has started successfully, you must activate your local environment. In a **new terminal window**, run the following commands:
    ```sh
    # Activate the python environment first
    source .venv/bin/activate

    # Activate the local orchestrate environment
    orchestrate env activate local

    # Start the chat UI
    orchestrate chat start
    ```
    You are now ready to develop and interact with your skills.

## Troubleshooting

#### `Cannot connect to the Docker daemon`

*   **Symptom**: The `docker` command fails.
*   **Solution**: Ensure the Colima VM is running (`colima status`). If not, start it with `colima start`. The installer script should handle this for you.

#### `401 Unauthorized` when starting the server

*   **Error**: The `orchestrate server start` command fails with `login attempt to cp.icr.io failed with status: 401 Unauthorized`.
*   **Solution**: This is an authentication error. The `WO_ENTITLEMENT_KEY` in your `.env` file is incorrect or has expired. You can obtain your key by following the instructions here: [Obtaining your entitlement key](https://www.ibm.com/docs/en/cloud-paks/1.0.0?topic=entitlements-obtaining-your-red-hat-entitlement-key).

#### Server Startup Timeout

*   **Error**: The server fails to start with a `ConnectionResetError` and a message about increasing the health timeout.
*   **Solution**: Open your `.env` file and add `HEALTH_TIMEOUT=900` to increase the startup timeout to 15 minutes.

## Cleanup

1.  **Stop the ADK Server**: Press `Ctrl+C` in the terminal where `orchestrate server start` is running. If that doesnt work, run `orchestrate server stop`.

2.  **Stop the Colima VM**: To free up system resources, stop the Colima machine.
    ```sh
    colima stop
    ```

3.  **Delete the Colima VM**: To completely remove the VM and all downloaded images, run:
    ```sh
    colima delete
    ```
# wxo-adk-on-colima
