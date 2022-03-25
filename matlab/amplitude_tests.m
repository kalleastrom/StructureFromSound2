aa = double(raw.aaint)'/(2^24);
bb = aa.^2;
for k = 1:15;
    bb = conv2(bb,ones(1,5)/5);
    bb = bb(:,2:2:end);
end

figure(1); clf;
plot(bb')


rr = gt.rgt;
ss = gt.sgt_resamp;
dd = toa_calc_d_from_xy(rr,ss);

%%
bb_meas = zeros(size(bb));
bb_calc = zeros(size(bb));
figure(1);
clf;
for i = 1:12;
    tmp1 = bb(i,:);
    tmp2 = 1./(dd(i,:)).^1;
    %tmp2 = tmp2(rouind(linspace(1,length(tmp2),length(tmp1))));
    tmp2 = tmp2(round(linspace(1,length(tmp2),length(tmp1))));
    oktmp = find(isfinite(tmp2));
    k = norm(tmp2(oktmp))/norm(tmp1(oktmp));
    tmp1 = tmp1*k;
    
    subplot(3,4,i);
    hold off;
    plot(tmp1);
    hold on;
    plot(tmp2);
    bb_meas(i,:)=tmp1;
    bb_calc(i,:)=tmp2;
    %pause;
end

%%
figure(2);
clf;
for i = 2:12;
   subplot(3,4,i);
    hold off;
    plot(bb_calc(i,:)./bb_calc(1,:));
    hold on;
    plot(bb_meas(i,:)./bb_meas(1,:));
end

%%

figure(30);
plot(bb_meas(:),bb_calc(:),'*')



%%

xl = -10:0.01:10;
T = 3*randn(1,5);
h = 0.1;
fl = zeros(size(xl));
for xi = 1:length(xl);
    x = xl(xi);
    fl(xi)= 1/(length(T))*sum((1/h)*(1/sqrt(2*pi))*exp(-((x-T)/h).^2/2) ) ;
end;
plot(xl,fl);
sum(fl)*0.01


