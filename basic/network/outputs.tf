output "vpc_id" {
  value = aws_vpc.tf_vpc.id
}

output "subnet_ids" {
  value = [aws_subnet.private_1.id,aws_subnet.private_2.id]
}
