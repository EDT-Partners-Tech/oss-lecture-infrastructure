# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "bedrock_agent_id" {
  value = aws_bedrockagent_agent.this.agent_id

}

output "bedrock_action_group_ids" {
  value = {
    for ag_name, ag in aws_bedrockagent_agent_action_group.ag :
    ag_name => ag.id
  }
}