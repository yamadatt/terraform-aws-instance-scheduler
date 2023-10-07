## 背景

AWSの利用料金を減らすため、使用していない夜間帯にEC2やRDSを落としたいです。

上記を実現するための検証することにしました。

## このリポジトリでできること

AWSに上記の検証環境をterraformで構築します。

## 具体的にどんなことをするか

2022年11月にアナウンスされたEventBridge Schedulerを使用します。

[Amazon EventBridge Scheduler \- Amazon EventBridge](https://docs.aws.amazon.com/ja_jp/eventbridge/latest/userguide/scheduler.html)

RDSとEC2の起動・停止の動作確認をします。そのため、RDSとEC2を作成します。

- RDSインスタンス
  - db.t4g.micro

- EC2インスタンス
  - t4g.nano

EC2は安いという理由でarm（intelじゃないので注意）を使用しています。停止・起動の確認するだけなので、一番安いのが良いです。

## 起動

以下のmain.tfを起動する。

    examples/simple/main.tf

## 注意事項

RDSのターゲットは変数で受け取れないので、以下のようにIdentifierを直接書くように。

    DbInstanceIdentifier = "test-db"


## 参考にしたリポジトリ

[littlejo/terraform\-aws\-instance\-scheduler: Stop and Start EC2 and RDS with eventbridge scheduler](https://github.com/littlejo/terraform-aws-instance-scheduler)