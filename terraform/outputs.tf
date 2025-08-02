output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.research_app.public_ip
}

output "streamlit_url" {
  description = "Streamlit URL to access the frontend"
  value       = "http://${aws_instance.research_app.public_ip}:8501"
}
