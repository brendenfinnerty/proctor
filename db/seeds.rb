survey = Survey.find_or_create_by!(title: "DX Branching Demo") do |s|
  s.description = "Demo survey with role-based branching"
end

q1 = survey.questions.find_or_create_by!(content: "Primary language?",      question_type: "multiple_choice", position: 1) { |q| q.options = %w[Ruby Python Go JS] }
q2 = survey.questions.find_or_create_by!(content: "Years of experience?",   question_type: "rating",          position: 2)
q3 = survey.questions.find_or_create_by!(content: "Frontend framework?",    question_type: "multiple_choice", position: 3) { |q| q.options = %w[React Vue Angular Svelte] }
q4 = survey.questions.find_or_create_by!(content: "Data pipeline tools?",   question_type: "checkbox",        position: 4) { |q| q.options = %w[Spark Kafka Airflow NiFi] }

roles = ["Data Engineer", "Frontend Engineer", "Product Manager"]
roles.each do |r|
  [q1, q2, q3, q4].each { |q| BranchRule.find_or_create_by!(survey:, question: q, role: r) { |br| br.visible = true } }
end

# Hide frontend question for Data Engineers; hide data tools for Frontend Engineers
BranchRule.find_or_create_by!(survey:, question: q3, role: "Data Engineer")        { |br| br.visible = false }
BranchRule.find_or_create_by!(survey:, question: q4, role: "Frontend Engineer")    { |br| br.visible = false }

puts "Seeded survey ##{survey.id} — visit /surveys/#{survey.id}/branching and /surveys/#{survey.id}/take"