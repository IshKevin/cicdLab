output "public_ip" {
  value = aws_instance.web.public_ip
}

output "key_name" {
  value = aws_key_pair.generated.key_name
}