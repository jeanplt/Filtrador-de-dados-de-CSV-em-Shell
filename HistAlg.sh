#!/bin/bash

# Este SCRIPT SHELL gera 4 arquivos a partir do arquivo CSV base, 1 arquivo para a primeira função e 3 arquivos para as funções de rol
# OBS: O arquivo CSV base foi renomeado para poder ser implementado neste SCRIPT SHELL, com a seguinte alteração:
# 'historico-alg1_SIGA_ANONIMIZADO' foi renomeado para 'historicoANONIMIZADO'

# Funcao que remove linhas de 2022 do 2o periodo para P. 1
Remove_2o_semestre22() 
{
    historicoANONIMIZADO_csv=$1
    Sem_2o_semestre22_csv=$2
    # Verifica se 'periodo' é diferente de 2 e 'ano' é diferente de 2022
    awk -F',' '$4 != 2 || $5 != 2022' "$historicoANONIMIZADO_csv" > "$Sem_2o_semestre22_csv"
}

# Função para calcular o numero de individuos por status para P. 2
Individuos_por_status() 
{
  Sem_2o_semestre22_csv="$1"
  
  awk -F',' '{
    if (NR > 1) 
        status[$10]++
  }
  END {
    print ""
    for (s in status) 
        print "Status", s, ":", status[s], "indivíduo(s)"
  }' "$Sem_2o_semestre22_csv"
}

# Funcao para calcular o numero maximo que alguem cursou Alg1 ate a aprovacao e seu mais individuos tiverem o mesmo valor pra P. 3
Max_cursada() 
{
  Sem_2o_semestre22_csv="$1"
  
  awk -F',' '{
    if ($10 != "Aprovado") 
    {
      matricula = $1
      cursadas[matricula]++
    }
    if ($10 == "Aprovado" && $1 == matricula)
        aprovou[matricula] = cursadas[matricula] + 1
    if (aprovou[matricula] > max_cursadas) 
        max_cursadas = aprovou[matricula]
  }
  END {
    for (cd in aprovou) {
      if (aprovou[cd] == max_cursadas) 
        indiv_id[cd] = 1
    }
    num_indiv = length(indiv_id)
    print ""
    print "Máximo de vezes cursadas até a aprovação:", max_cursadas
    print "Número de indivíduos com máximo de vezes cursadas:", num_indiv
    print ""
  }' "$Sem_2o_semestre22_csv"
}

# Funcao para calcular porcentagens de aprovacao, reprovacao e evasao de cada ano para P. 4 e P. 8
Porcent_aprov_reprov_ev_ano() 
{
    Sem_2o_semestre22_csv="$1"

    awk -F',' '{
        if (NR > 1)
        {
            if ($10 == "Aprovado")
                aprovados_por_ano[$5]++
            if ($10 == "Reprovado" || $10 == "R-freq" || $10 == "R-nota")
                reprovados_por_ano[$5]++
            if ($14 == "Evasão")
            {
                evasoes_ano[$5]++
                evasao_total++
            }
            total_por_ano[$5]++
            tudo++
        }
    }
    END {
        todas_evasoes = evasao_total
        all = tudo
        porcentagem_total_evasao = (todas_evasoes / all) * 100
        printf "Porcentagem total de Evasão: %.2f%%\n", porcentagem_total_evasao
        print ""
        printf "Porcentagens Anuais"
        for (ano in total_por_ano) 
        {
            total = total_por_ano[ano]
            aprovados = aprovados_por_ano[ano] 
            reprovados = reprovados_por_ano[ano] 
            evasoes = evasoes_ano[ano]
            porcentagem_aprovacao = (aprovados / total) * 100
            porcentagem_reprovacao = (reprovados / total) * 100
            porcentagem_evasao = (evasoes / total) * 100
            printf "\nAno: %s\n", ano
            printf "Porcentagem de Aprovação: %.2f%%\n", porcentagem_aprovacao
            printf "Porcentagem de Reprovação: %.2f%%\n", porcentagem_reprovacao
            printf "Porcentagem de Evasões: %.2f%%\n", porcentagem_evasao
            print ""
        }
    }' "$Sem_2o_semestre22_csv"
}

# Funcao para calcular media de notas e frequencias por anos para P. 5 e P. 6 e P. 7
Media_notas_freq_ano()
{
    Sem_2o_semestre22_csv="$1"

    awk -F',' '{
        if (NR > 1 && $10 == "Aprovado")
        {
            soma_notas_aprov[$5] += $8
            aprov_ano[$5]++
        }
        else if (NR > 1 && $10 == "R-nota")
        {
            soma_notas_reprov[$5] += $8
            soma_freq[$5] += $9
            reprov_ano[$5]++
        }
    }
    END {
        printf "Médias Anuais"
        for (ano in aprov_ano) 
        {
            aprovs = aprov_ano[ano]
            reprovs = reprov_ano[ano]
            soma_a = soma_notas_aprov[ano]
            soma_r = soma_notas_reprov[ano]
            soma_f = soma_freq[ano] 
            if (aprovs > 0)
            {
                media_a = soma_a / aprovs
                printf "\nAno: %s\n", ano
                printf "Média de nota dos Aprovados: %.2f\n", media_a
            }
            else
            {
                printf "\nAno: %s\n", ano
                print "Sem aprovados no ano"
            }
            
            if (reprovs > 0)
            {
                media_r = soma_r / reprovs
                media_f = soma_f / reprovs
                printf "Média de nota dos Reprovados por nota: %.2f\n", media_r
                printf "Média de frequência dos Reprovados por nota: %.2f\n", media_f
            }
            else
            {
                print "Sem reprovados por nota"
            }
        }
    }' "$Sem_2o_semestre22_csv"
}

# Funcao para calcular rendimentos para P. 9
Rendimentos()
{
    Sem_2o_semestre22_csv="$1"

    awk -F',' '{
        if (NR > 1)
        {
            if ($5 < 2020)
            {
                if ($10 == "Aprovado")
                    aprov_ant++
                if ($10 == "Cancelado")
                    cancel_ant++
                if ($10 == "R-freq" || $10 == "R-nota" || $10 == "Reprovado")
                    reprov_ant++
                todos_ant++
            }
            if ($5 == 2020 || $5 == 2021)
            {
                if ($10 == "Aprovado")
                    aprov_pan++
                if ($10 == "Cancelado")
                    cancel_pan++
                if ($10 == "R-freq" || $10 == "R-nota" || $10 == "Reprovado")
                    reprov_pan++
                todos_pan++
            }
        }
    }
    END {
        aprovs1 = aprov_ant
        aprovs2 = aprov_pan
        cancel1 = cancel_ant
        cancel2 = cancel_pan
        reprovs1 = reprov_ant
        reprovs2 = reprov_pan
        todos1 = todos_ant
        todos2 = todos_pan
        rend_ant = ( aprovs1 / todos1 ) * 100
        rend_pan = (aprovs2 / todos2 ) * 100
        taxa1 = ( cancel1 / todos1 ) * 100
        taxa2 = ( cancel2 / todos2 ) * 100
        taxa3 = ( reprovs1 / todos1 ) * 100
        taxa4 = ( reprovs2 / todos2 ) * 100
        dif = rend_ant - rend_pan
        dif2 = taxa2 - taxa1
        dif3 = taxa4 - taxa3
        print ""
        print "Rendimentos"
        printf "O Rendimento dos aprovados pré Pandemia foi de %.2f%%, ", rend_ant
        printf "Enquanto o Rendimento dos aprovados na Pandemia foi de %.2f%%\n", rend_pan
        printf "Isso representa uma diminuição do rendimento em %.2f%%\n", dif
        print ""
        printf "Taxa de cancelamento pré Pandemia: %.2f%%\n", taxa1
        printf "Taxa de cancelamento na Pandemia: %.2f%%\n", taxa2
        printf "Aumento de cancelamento em %.2f%%\n", dif2
        print ""
        printf "Taxa de reprovação pré Pandemia: %.2f%%\n", taxa3
        printf "Taxa de reprovação na Pandemia: %.2f%%\n", taxa4
        printf "Aumento de reprovação em %.2f%%\n", dif3
        print ""
    }' "$Sem_2o_semestre22_csv"
}

# Função para criar o rol das notas antes de 2020 para P. 10
Cria_rol()  
{
    Sem_2o_semestre22_csv="$1"
    # Rol para mediana dos anos anteriores a 2022
    rol_csv="$2"

    # Verifica as notas antes de 2020 para formar um rol
    awk -F',' '{ if (NR > 1 && $5 < 2020) print $8 }' "$Sem_2o_semestre22_csv" | sort -n > "$rol_csv" 

    # Calcula a mediana antes de 2020
    tam_rol=$(wc -l < "$rol_csv")
    meio=$((tam_rol / 2))
    if ((tam_rol % 2 == 0)); then
        mediana3=$(sed -n "${meio}p" "$rol_csv")
    else
        mediana3=$(sed -n "${meio}p;$((meio + 1))p" "$rol_csv" | awk '{ sum += $1 } END { print sum / 2 }')
    fi

    echo "Medianas"
    echo "Antes da Pandemia: $mediana3"

}

# Função para criar o rol das notas na pandemia para P. 10
Cria_rol_pan()  
{
    Sem_2o_semestre22_csv="$1"
    # Rol para mediana dos anos anteriores a 2022
    rol_pan_csv="$2"

    # Verifica as notas com base em 2020 e 2021 para formar um rol
    awk -F',' '{ if (NR > 1 && $5 == 2020 || $5 == 2021) print $8 }' "$Sem_2o_semestre22_csv" | sort -n > "$rol_pan_csv" 

    # Calcula a mediana da pandemia
    tam_rol=$(wc -l < "$rol_pan_csv")
    meio=$((tam_rol / 2))
    if ((tam_rol % 2 == 0)); then
        mediana2=$(sed -n "${meio}p" "$rol_pan_csv")
    else
        mediana2=$(sed -n "${meio}p;$((meio + 1))p" "$rol_pan_csv" | awk '{ sum += $1 } END { print sum / 2 }')
    fi

    echo "Pandemia: $mediana2"
}

# Função para criar o rol das notas de 2022 para P. 10
Cria_rol22()  
{
    Sem_2o_semestre22_csv="$1"
    # Rol para mediana de 2022
    rol_22_csv="$2"

    # Verifica as notas com base em 2022 para formar um rol
    awk -F',' '{ if (NR > 1 && $5 == 2022) print $8 }' "$Sem_2o_semestre22_csv" | sort -n > "$rol_22_csv"

    # Calcula a mediana de 2022
    tam_rol=$(wc -l < "$rol_22_csv")
    meio=$((tam_rol / 2))
    if ((tam_rol % 2 == 0)); then
        mediana=$(sed -n "${meio}p" "$rol_22_csv")
    else
        mediana=$(sed -n "${meio}p;$((meio + 1))p" "$rol_22_csv" | awk '{ sum += $1 } END { print sum / 2 }')
    fi

    echo "Pós-Pandemia (2022): $mediana"
    echo "Percebe-se que houve um aumento gradativo das medianas devido a Pandemia e pós-Pandemia"
}

aprovs_reprovs_cancels()
{
    Sem_2o_semestre22_csv="$1"

    awk -F',' '{
        if (NR > 1)
        {
            if ($5 < 2020)
            {
                if ($10 == "Aprovado")
                    aprov_ant++
                if ($10 == "Cancelado")
                    cancel_ant++
                if ($10 == "R-freq" || $10 == "R-nota" || $10 == "Reprovado")
                    reprov_ant++
            }
            else if ($5 == 2020 || $5 == 2021)
            {
                if ($10 == "Aprovado")
                    aprov_pan++
                if ($10 == "Cancelado")
                    cancel_pan++
                if ($10 == "R-freq" || $10 == "R-nota" || $10 == "Reprovado")
                    reprov_pan++
            }
            else if ($5 == 2022)
            {
                if ($10 == "Aprovado")
                    aprov_22++
                if ($10 == "Cancelado")
                    cancel_22++
                if ($10 == "R-freq" || $10 == "R-nota" || $10 == "Reprovado")
                    reprov_22++
            }
        }
    }
    END {
        ap1 = aprov_ant
        ap2 = aprov_pan
        ap3 = aprov_22
        can1 = cancel_ant
        can2 = cancel_pan
        can3 = cancel_22
        rep1 = reprov_ant
        rep2 = reprov_pan
        rep3 = reprov_22
        print ""
        printf "O numero de aprovados em 2022 foi de %d, enquanto na pandemia foi de %d.\n", ap3, ap2
        printf "Já nos anos anteriores foi de %d\n", ap1
        print ""
        printf "O numero de cancelamentos em 2022 foi de %d, enquanto na pandemia foi de %d.\n", can3, can2
        printf "Já nos anos anteriores foi de %d\n", can1
        print ""
        printf "O numero de reprovações em 2022 foi de %d, enquanto na pandemia foi de %d.\n", rep3, rep2
        printf "Já nos anos anteriores foi de %d\n", rep1
        print ""
    }' "$Sem_2o_semestre22_csv"
}

Remove_2o_semestre22 "historicoANONIMIZADO.csv" "Sem_2o_semestre22.csv" # P. 1 ok

Individuos_por_status "Sem_2o_semestre22.csv" # P. 2 ok

Max_cursada "Sem_2o_semestre22.csv" # P. 3 ok

Porcent_aprov_reprov_ev_ano "Sem_2o_semestre22.csv" # P. 4 ok

Media_notas_freq_ano "Sem_2o_semestre22.csv" # P. 5 , P. 6 e P. 7 ok

Rendimentos "Sem_2o_semestre22.csv" # P. 9 ok

Cria_rol "Sem_2o_semestre22.csv" "rol.csv" 

Cria_rol_pan "Sem_2o_semestre22.csv" "rol_pan.csv"

Cria_rol22 "Sem_2o_semestre22.csv" "rol_22.csv"

aprovs_reprovs_cancels "Sem_2o_semestre22.csv"

# Quatro funcoes acima: P. 10 ok