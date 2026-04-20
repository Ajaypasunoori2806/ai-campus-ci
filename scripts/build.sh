cat > scripts/build.sh << 'EOF'
#!/bin/bash
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Build completed"
EOF