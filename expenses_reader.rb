require 'rexml/document' # подключаем парсер
require 'date' # будем работать с датой

# запишем путь к файлу, лежащему в том же каталоге
current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml"

# если файл не найден закрываем программу
unless File.exist?(file_name)
  abort "Извините, хозяин, файлик #{file_name} не найден"
end

# Открываем файл и записываем дескриптор в переменную file
file = File.new(file_name, 'r:UTF-8')

begin
  # Пробуем считать содержимое файла с помощью библиотеки rexml. Создаем новый
  # объект класса REXML::Document, построенный из открытого файла XML
  doc = REXML::Document.new(file)
rescue REMXL::ParseExceptiom => e # если парсер ошибся при четении файла, придется закрыть программу
  puts "XML файл похоже битый :("
  abort e.message
end

file.close

# Создадим пустой ассоциативный массив amount_by_day, куда сложим все траты подням в формате
#
# {
#  день1: сумма трат в день1,
#  день2: сумма трат в день2,
#  ...
# }
#

amount_by_day = {}

# Выберем из элементов документа все тэги <expenses> и в 
# цикле проходимся по ним.
doc.elements.each('expenses/expense') do |item|
  # в локальную переменную занесем траты
  loss_sum = item.attributes['amount'].to_i

  loss_date = Date.parse(item.attributes['date'])

  # Иницилизируем нулем значение хеша, соответствуещего нужному дню
  # если этой даты еще не было/ запись эквивалента 
  # amount_by_day[loss_date] = 0 if amount_by_day[loss_date] = nil
  amount_by_day[loss_date] ||= 0

  # Увеличиваем в хэшн  нужное значение на сумму трат
  amount_by_day[loss_date] += loss_sum
end

# создадим хэш сумму расходов за месяц
sum_by_month = {}

# В цикле по всем датам хэша amount_by_day накопим в хэше sum_by_month значения
# потраченных сумм каждого дня
amount_by_day.keys.sort.each do |key|
  # key.strftime(%B %Y) вернет одинаковую строку для всех дней одного месяца
  # поэтому можем использовать ее как уникальный для каждого месяца ключ
  sum_by_month[key.strftime('%B %Y')] ||= 0

  # Приплюсуем к тому что было сумму следующего дня
  sum_by_month[key.strftime('%B %Y')] += amount_by_day[key]
end

# Пришло время выводить статистику на экран в цикле пройдемся по всем месяцам 
# и начнем с первого 
current_month = amount_by_day.keys.sort[0].strftime('%B %Y')

# Выводим заголовок для первого месяца
puts "________[ #{current_month}, всего потрачено:" \
  "#{sum_by_month[current_month]} p. ]_______________"

# цикл по всем дням

amount_by_day.keys.sort.each do |key|
  # если текущий день принадлежит уже другому месяцу
  if key.strftime('%B %Y') != current_month 
    # то значит мы перешли на новый месяц и теперь он станет текущим
    current_month = key.strftime('%B %Y')

    # Выводим заголовок для нового текущего месяца
    puts "________[ #{current_month}, всего потрачено:" \
  "#{sum_by_month[current_month]} p. ]_______________"
  end
  # Выводим расходы за день
  puts "\t#{key.day}: #{amount_by_day[key]} р."
end