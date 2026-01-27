#!/bin/bash

# Test script for validating skill installation methods
# This script tests all three installation methods documented in README.md

set -e  # Exit on error

INSTALL_DIR="/tmp/skill-install-test"
TEST_SKILL_PATH="steipete/discord"
TEST_SKILL_NAME="discord"

echo "=========================================="
echo "Testing Clawdbot Skill Installation Methods"
echo "=========================================="
echo ""

# Clean up any previous test runs
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Test 1: curl method
echo "Test 1: Installing with curl..."
mkdir -p "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}"
curl -L "https://github.com/clawdbot/skills/archive/refs/heads/main.tar.gz" 2>/dev/null | \
  tar -xz --strip-components=4 -C "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}" "skills-main/skills/${TEST_SKILL_PATH}"

if [[ -f "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}/SKILL.md" ]] && \
   [[ -f "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}/_meta.json" ]]; then
  echo "✓ curl installation successful"
else
  echo "✗ curl installation failed"
  exit 1
fi
echo ""

# Test 2: wget method
echo "Test 2: Installing with wget..."
mkdir -p "$INSTALL_DIR/wget-test/${TEST_SKILL_NAME}"
wget -qO- "https://github.com/clawdbot/skills/archive/refs/heads/main.tar.gz" | \
  tar -xz --strip-components=4 -C "$INSTALL_DIR/wget-test/${TEST_SKILL_NAME}" "skills-main/skills/${TEST_SKILL_PATH}"

if [[ -f "$INSTALL_DIR/wget-test/${TEST_SKILL_NAME}/SKILL.md" ]] && \
   [[ -f "$INSTALL_DIR/wget-test/${TEST_SKILL_NAME}/_meta.json" ]]; then
  echo "✓ wget installation successful"
else
  echo "✗ wget installation failed"
  exit 1
fi
echo ""

# Test 3: git sparse checkout method
echo "Test 3: Installing with git sparse checkout..."
mkdir -p "$INSTALL_DIR/git-test/${TEST_SKILL_NAME}"
cd "$INSTALL_DIR/git-test/${TEST_SKILL_NAME}"
git init -q
git remote add origin https://github.com/clawdbot/skills.git
git config core.sparseCheckout true
echo "skills/${TEST_SKILL_PATH}/*" >> .git/info/sparse-checkout
git pull -q origin main 2>/dev/null
mv "skills/${TEST_SKILL_PATH}/"* .
rm -rf skills .git

if [[ -f "$INSTALL_DIR/git-test/${TEST_SKILL_NAME}/SKILL.md" ]] && \
   [[ -f "$INSTALL_DIR/git-test/${TEST_SKILL_NAME}/_meta.json" ]]; then
  echo "✓ git sparse checkout installation successful"
else
  echo "✗ git sparse checkout installation failed"
  exit 1
fi
echo ""

# Verify all three methods produced the same files
echo "Test 4: Verifying all methods produce identical results..."
CURL_FILES=$(cd "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}" && find . -type f | sort)
WGET_FILES=$(cd "$INSTALL_DIR/wget-test/${TEST_SKILL_NAME}" && find . -type f | sort)
GIT_FILES=$(cd "$INSTALL_DIR/git-test/${TEST_SKILL_NAME}" && find . -type f | sort)

if [[ "$CURL_FILES" == "$WGET_FILES" ]] && [[ "$WGET_FILES" == "$GIT_FILES" ]]; then
  echo "✓ All methods produce identical file structure"
else
  echo "✗ Methods produced different file structures"
  echo "curl files: $CURL_FILES"
  echo "wget files: $WGET_FILES"
  echo "git files: $GIT_FILES"
  exit 1
fi
echo ""

echo "=========================================="
echo "All installation methods passed!"
echo "=========================================="
echo ""
echo "Installed files:"
ls -l "$INSTALL_DIR/curl-test/${TEST_SKILL_NAME}"

# Clean up
rm -rf "$INSTALL_DIR"
