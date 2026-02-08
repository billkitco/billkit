## Setup

The `setup-dev.sh` script clones all required repositories and sets up the development environment:

- **Frontend**: `billkit-frontend` repository
- **Backend**: `billkit-backend` repository  
- **Environment files**: Clones private env repos and copies `.env` files to frontend/backend directories
- **Dependencies**: Installs Python dependencies (backend) and npm packages (frontend)

### Prerequisites

- SSH access to billkitco GitHub repositories (configured via `~/.ssh/config` with `billkitco` host alias)
- Python 3 with `venv` module
- Node.js and npm

### Usage

```bash
chmod +x setup-dev.sh
./setup-dev.sh [ROOT_DIR]
```

The script accepts an optional `ROOT_DIR` argument. If not provided, it uses the current directory. The script will create `frontend/` and `backend/` directories in the specified root.