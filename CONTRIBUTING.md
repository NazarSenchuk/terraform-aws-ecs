# Contributing to AWS ECS Infrastructure

Thank you for your interest in contributing to this project! We welcome all contributions, from bug reports and feature requests to code changes and documentation improvements.

## 🛠 Development Workflow

1. **Fork the Repository**: Create your own copy of the repository.
2. **Clone forked repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/awsecs.git
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
4. **Run Terraform Validations**:
   Ensure your changes are syntactically correct and follow best practices:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```
5. **Commit Your Changes**:
   Follow conventional commits if possible (e.g., `feat: add arm64 support`).
6. **Push and Pull Request**:
   Push to your fork and submit a PR to the main repository.

## 📏 Coding Standards

- **Terraform Version**: Always target the version specified in `main.tf`.
- **Formatting**: Always run `terraform fmt` before committing.
- **Variables**: Document all new variables in `variables.tf` and provide examples in `attributes.tfvars`.
- **Modules**: Keep modules focused and reusable. Use descriptive names for resources.

## 🐛 Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem.
- Steps to reproduce.
- Your Terraform and Provider versions.
- (Optional) Relevant log outputs.

## 💡 Feature Requests

We love new ideas! Please open an issue to discuss major changes before starting work on them.
