require 'xlua'
xrequire ('nnx', true)
require "nn"
dofile('tokenizer.lua')
dofile('loadEmbeddings.lua')

-- Function to shuffle two tables t1 and t2
function shuffle(t1,t2)
  local n = #t1
 print("sizet1"..#t1)
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
      temp = t1[n]
      t1[n] = t1[k]
      t1[k] = temp
      temp = t2[n]
      t2[n] = t2[k]
      t2[k] = temp
    n = n - 1
  end 
  return t2
end

function getReviewDataset(fileName,label, fileName2, label2)
   max_size = 0
   i=1
   tokens = {};
   for temp in io.lines(fileName) do
      tokens[i] = tokenizer(temp)
      i = i + 1
   end
   i = i - 1

   input = {} --torch.Tensor(i);
   output = {}
   for j = 1, i do
      input_j = {}--torch.Tensor(2400) --{}
      k = 1
      for type,value in tokens[j] do
         input_j[k] = value
         k = k + 1
      end
      input_jt = torch.Tensor(51)
      sizej = #input_j
    if(sizej > max_size) then
         max_size = sizej
      end
      if sizej > 51 then sizej = 51 end
      for k=1,sizej do input_jt[k] = input_j[k] end
 
      --add padding--
      if #input_j < 51 then 
         for k=1+#input_j,51 do input_jt[k] = 1739 end
      end
      input[j] = input_jt
          local tens = torch.Tensor(2);
      tens[1] = 1;
      tens[2] = 0;
      output[j] = tens
 
   end
   
   i=1
   tokens = {};
   for temp in io.lines(fileName2) do
      tokens[i] = tokenizer(temp)
      i = i + 1
      --print(#temp)
   end
   i = i - 1
   
   input2 = {} --torch.Tensor(i);
   output2 = {}
   for j = 1, i do
      input_j = {} --torch.Tensor(2400)
      k = 1
      for type,value in tokens[j] do
         input_j[k] = value
         k = k + 1
      end
      input_jt = torch.Tensor(51)
      sizej = #input_j
    if(sizej > max_size) then
         max_size = sizej
      end
      if sizej > 51 then sizej = 51 end
      for k=1,sizej do input_jt[k] = input_j[k] end
      --add padding--
      if #input_j < 51 then 
         for k=1+#input_j,51 do input_jt[k] = 1739 end
      end
      input2[j] = input_jt
      local tens = torch.Tensor(2);
      tens[1] = 0;
      tens[2] = 1;
      output2[j] = tens
   end
         print("MAX SIZE:"..max_size)
   -- now concatenate both tables
   size2 = #input
   for k,v in pairs(input2) do input[k + size2] = v end
   for k,v in pairs(output2) do output[k + size2] = v end
   print("size of input:"..#input)
   print("size of output:"..#output)
   local dataset = {}
   shuffle(input,output)
   for i=1,#output do dataset[i] = {input[i], output[i]} end
   function dataset:size() return #dataset end
  print("dataset size:"..dataset.size())   
   return dataset

end

function padDataset(dset)

end

train_dataset = getReviewDataset('encoded_pos_snippets_train.txt',1,
                                 'encoded_neg_snippets_train.txt',2)
test_dataset = getReviewDataset('encoded_pos_snippets_test.txt',1,
                                'encoded_neg_snippets_test.txt',2)


--[[
print(var1:size(1).."x"..var1:size(2))
module = nn.LookupTable(150000, 50)
var2=module:forward(var1)
print(var2:size(1).."x"..var2:size(2))
module2 = nn.TemporalConvolution(50,100,5,1)
     var3=module2:forward(var2)
print(var3:size(1).."x"..var3:size(2))
module3 = nn.TemporalSubSampling(100, 10, 3)
     var4=module3:forward(var3)
print(var4:size(1).."x"..var4:size(2))
module4 = nn.Linear(100,35)
     var5=module4:forward(var4)
print(var5:size(1).."x"..var5:size(2))
module5 = nn.HardTanh()
     var6=module5:forward(var5)
print(var6:size(1).."x"..var6:size(2))
     module6 = nn.Linear(35,2)

     var7=module6:forward(var6)
     print(var7:size(1).."x"..var7:size(2))
     ---------------------------------------
var1=train_dataset[1][1]
print(var1:size(1))
module = nn.LookupTable(150000, 50)
     var2=module:forward(var1)
print(var2:size(1).."x"..var2:size(2))
module2 = nn.TemporalConvolution(50,500,5,1)
     var3=module2:forward(var2)
print(var3:size(1).."x"..var3:size(2))
module3 = nn.TemporalSubSampling(500, 8, 8)
var4=module3:forward(var3)
print(var4:size(1).."x"..var4:size(2))
module9 = nn.TemporalConvolution(500,500,5,1)
     var9=module9:forward(var4)
print(var9:size(1).."x"..var9:size(2))
module4 = nn.Linear(500,1000)
     var5=module4:forward(var9)
print(var5:size(1).."x"..var5:size(2))
module5 = nn.HardTanh()
     var6=module5:forward(var5)
print(var6:size(1).."x"..var6:size(2))
     module6 = nn.Linear(1000,1)
     var7=module6:forward(var6)
print(var7:size(1).."x"..var7:size(2))

     

]]--

snlp = nn.Sequential();
module1 = nn.LookupTable(130000, 50)
--weights = loadEmbeddings('embeddings.txt',130000)
module1.weight=weights;
snlp:add(module1)
snlp:add(nn.TemporalConvolution(50,500,5,1))
snlp:add(nn.TemporalSubSampling(500, 8, 8))
snlp:add(nn.TemporalConvolution(500,500,5,1))
snlp:add(nn.Linear(500,1000))
snlp:add(nn.HardTanh())
snlp:add(nn.Linear(1000,1))
criterion = nn.MSECriterion()  
--criterion.sizeAverage = false
--criterion = nn.ClassNLLCriterion()
--trainer = nn.StochasticGradient(snlp, criterion)
--trainer.learningRate = 0.01
--trainer:train(train_dataset)

optimizer = nn.SGDOptimization{module = snlp,
                                     criterion = criterion,
                                     parallelize = 1,
                                     learningRate = 1e-4,
                                     weightDecay = 1e-6,
                                     learningRateDecay = 5e-7,
                                     momentum = 0.5}
dispProgress = true

batchSize = 1

trainer = nn.OnlineTrainer{module = snlp,
                           criterion = criterion,
                           optimizer = optimizer,
                           maxEpoch = 100,
                           dispProgress = dispProgress,
                           batchSize = batchSize,
                           save = 'snlp.net'}


trainer.hookTrainEpoch = function(trainer)
                            -- run on test_set
                            trainer:test(test_dataset)
   end
--trainer:train(train_dataset)
