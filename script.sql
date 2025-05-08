-- View to show the current stock

CREATE VIEW vw_EstoqueAtual AS
SELECT
    p.ProdutoId,
    p.Nome,
    p.Preco,
    p.Quantidade AS EstoqueDisponivel,
    CASE
        WHEN p.Quantidade = 0 THEN 'Sem estoque'
        WHEN p.Quantidade < 5 THEN 'Baixo estoque'
        ELSE 'Estoque normal'
    END AS StatusEstoque
FROM
    Produtos p;

-- Trigger to update automatically the stock when a sale is made

  CREATE TRIGGER trg_AtualizaEstoque_AposVenda
ON Vendas
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.Quantidade = p.Quantidade - i.QuantidadeVendida
    FROM Produtos p
    INNER JOIN inserted i ON p.ProdutoId = i.ProdutoId;
    
    PRINT 'Estoque atualizado após venda.';
END;

--  Procedure to register a new sale

CREATE PROCEDURE sp_RegistrarVenda
    @ProdutoId INT,
    @QuantidadeVendida INT
AS
BEGIN
    DECLARE @EstoqueAtual INT;

    SELECT @EstoqueAtual = Quantidade
    FROM Produtos
    WHERE ProdutoId = @ProdutoId;

    IF @EstoqueAtual IS NULL
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END

    IF @EstoqueAtual < @QuantidadeVendida
    BEGIN
        RAISERROR('Estoque insuficiente.', 16, 1);
        RETURN;
    END

    INSERT INTO Vendas (ProdutoId, QuantidadeVendida, DataVenda)
    VALUES (@ProdutoId, @QuantidadeVendida, GETDATE());

    PRINT 'Venda registrada com sucesso.';
END;

-- Executing PROCEDURE

EXEC sp_RegistrarVenda @ProdutoId = 1, @QuantidadeVendida = 3;
